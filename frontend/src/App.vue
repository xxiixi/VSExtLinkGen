<template>
  <div class="bg-gray-50 min-h-screen font-sans">
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-indigo-600 mb-2">
          VS Extension Link Generator
        </h1>
        <p class="text-gray-600 text-base">输入插件链接，自动生成下载链接</p>
      </div>

      <!-- 输入区域 -->
      <div
        class="bg-white rounded-xl shadow-md p-6 mb-8 card-hover transition-all"
      >
        <!-- URL输入 -->
        <div class="mb-6">
          <label
            for="pluginUrl"
            class="block text-sm font-medium text-gray-700 mb-2"
            >插件链接 <span class="text-red-500">*</span></label
          >
          <input
            type="text"
            id="pluginUrl"
            v-model="pluginUrl"
            class="w-full rounded-lg border border-gray-300 px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-shadow"
            placeholder="请输入VS Code插件市场链接"
          />
          <p class="text-gray-500 text-xs mt-1.5">
            输入插件链接，系统将自动提取发布者、插件名称和版本信息
          </p>
        </div>

        <button
          @click="generateLinks"
          :disabled="isLoading"
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-400 text-white px-6 py-2.5 rounded-lg transition-all font-medium shadow-sm hover:shadow"
        >
          <i
            :class="isLoading ? 'fas fa-spinner fa-spin' : 'fas fa-link'"
            class="mr-2"
          ></i>
          {{ isLoading ? "获取插件信息中..." : "生成下载链接" }}
        </button>
      </div>

      <!-- 结果区域 -->
      <div class="fade-in result-container">
        <!-- 平台无关链接 -->
        <div
          class="bg-white rounded-xl shadow-md p-6 mb-6 card-hover transition-all"
        >
          <h2
            class="text-xl font-semibold text-gray-800 mb-4 flex items-center"
          >
            <i class="fas fa-globe text-indigo-500 mr-2"></i>下载链接 1
            (平台无关)
          </h2>
          <div class="flex">
            <input
              type="text"
              :value="platformIndependentLink || '未生成'"
              class="flex-1 rounded-l-lg border border-gray-300 px-4 py-2.5 bg-gray-50 text-gray-700 text-sm"
              readonly
              placeholder="未生成"
            />
            <button
              @click="copyToClipboard(platformIndependentLink)"
              class="bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-2.5 transition-colors"
              :disabled="!platformIndependentLink"
            >
              <i class="fas fa-copy mr-1.5"></i>复制
            </button>
            <button
              @click="downloadLink(platformIndependentLink)"
              class="bg-green-600 hover:bg-green-700 text-white px-3 py-2.5 rounded-r-lg transition-colors"
              :disabled="!platformIndependentLink"
            >
              <i class="fas fa-download mr-1.5"></i>下载
            </button>
          </div>
        </div>

        <!-- 平台相关链接 -->
        <div
          class="bg-white rounded-xl shadow-md p-6 card-hover transition-all"
        >
          <h2
            class="text-xl font-semibold text-gray-800 mb-4 flex items-center"
          >
            <i class="fas fa-desktop text-indigo-500 mr-2"></i>下载链接 2
            (平台相关)
          </h2>
          <div v-for="platform in platforms" :key="platform" class="mb-4">
            <!-- 平台小标题 -->
            <div class="text-sm font-medium text-gray-500 mb-2">
              {{ getPlatformTitle(platform) }}
            </div>
            <div class="flex">
              <input
                type="text"
                :value="generatePlatformDependentLink(platform)"
                class="flex-1 rounded-l-lg border border-gray-300 px-4 py-2.5 bg-gray-50 text-gray-700 text-sm"
                readonly
                :placeholder="`${platform}平台下载链接`"
              />
              <button
                @click="
                  copyToClipboard(generatePlatformDependentLink(platform))
                "
                class="bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-2.5 transition-colors"
                :disabled="!platformIndependentLink"
              >
                <i class="fas fa-copy mr-1.5"></i>复制
              </button>
              <button
                @click="downloadLink(generatePlatformDependentLink(platform))"
                class="bg-green-600 hover:bg-green-700 text-white px-3 py-2.5 rounded-r-lg transition-colors"
                :disabled="!platformIndependentLink"
              >
                <i class="fas fa-download mr-1.5"></i>下载
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 提示消息容器 -->
      <div
        v-if="toastMessage"
        class="fixed bottom-4 left-1/2 transform -translate-x-1/2 z-50"
      >
        <div
          :class="[
            'toast px-4 py-2.5 rounded-lg shadow-lg mb-2 flex items-center',
            toastType === 'error'
              ? 'bg-red-500 text-white'
              : 'bg-green-500 text-white',
          ]"
        >
          <i
            :class="
              toastType === 'error'
                ? 'fas fa-exclamation-circle'
                : 'fas fa-check-circle'
            "
            class="mr-2"
          ></i>
          {{ toastMessage }}
        </div>
      </div>
    </div>

    <footer class="bg-gray-100 py-4 mt-10">
      <div class="container mx-auto px-4 text-center text-gray-500 text-sm">
        <p>VS Extension Link Generator © 2023</p>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: "App",
  data() {
    return {
      pluginUrl: "",
      isLoading: false,
      extractedData: null,
      platformIndependentLink: "",
      platforms: ["win32-x64", "linux-x64", "darwin-x64", "darwin-arm64"],
      toastMessage: "",
      toastType: "success",
    };
  },
  methods: {
    async generateLinks() {
      if (!this.pluginUrl.trim()) {
        this.showToast("请输入插件链接", "error");
        return;
      }

      this.isLoading = true;

      try {
        const response = await fetch("/extract-data", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ url: this.pluginUrl }),
        });

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || "获取插件信息失败");
        }

        const data = await response.json();

        if (!data.publisher || !data.plugin_name || !data.version) {
          throw new Error("无法从链接中提取完整的插件信息");
        }

        this.extractedData = data;
        this.platformIndependentLink = `https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${encodeURIComponent(
          data.publisher
        )}/vsextensions/${encodeURIComponent(
          data.plugin_name
        )}/${encodeURIComponent(data.version)}/vspackage`;

        this.showToast("插件信息获取成功，已生成下载链接");
      } catch (error) {
        console.error("Error:", error);
        this.showToast(error.message || "获取插件信息时发生错误", "error");
      } finally {
        this.isLoading = false;
      }
    },

    generatePlatformDependentLink(platform) {
      if (!this.platformIndependentLink) return "";
      const baseUrl = this.platformIndependentLink.split("/vspackage")[0];
      return `${baseUrl}?targetPlatform=${encodeURIComponent(platform)}`;
    },

    getPlatformTitle(platform) {
      const platformMap = {
        "win32-x64": "Windows (x64)",
        "linux-x64": "Linux (x64)",
        "darwin-x64": "macOS (Intel)",
        "darwin-arm64": "macOS (Apple Silicon)",
      };
      return platformMap[platform] || platform;
    },

    copyToClipboard(text) {
      if (!text) return;

      navigator.clipboard
        .writeText(text)
        .then(() => {
          this.showToast("链接已复制到剪贴板");
        })
        .catch(() => {
          const textArea = document.createElement("textarea");
          textArea.value = text;
          document.body.appendChild(textArea);
          textArea.select();
          document.execCommand("copy");
          document.body.removeChild(textArea);
          this.showToast("链接已复制到剪贴板");
        });
    },

    downloadLink(url) {
      if (!url) return;

      const link = document.createElement("a");
      link.href = url;
      link.download = "";
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      this.showToast("下载已开始");
    },

    showToast(message, type = "success") {
      this.toastMessage = message;
      this.toastType = type;
      setTimeout(() => {
        this.toastMessage = "";
      }, 3000);
    },
  },
};
</script>
