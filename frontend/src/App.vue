<template>
  <div class="bg-gray-50 min-h-screen">
    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-indigo-600 mb-2">
            VS Extension Link Generator
        </h1>
        <p class="text-gray-600">Input the plugin link, and the system will automatically generate the download link</p>
      </div>

      <!-- 输入区域 -->
      <div class="bg-white rounded-xl shadow-md p-6 mb-8 card-hover">
        <!-- 引导提示 -->
        <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-6">
          <div class="flex">
            <div class="flex-shrink-0">
              <i class="fas fa-info-circle text-blue-500"></i>
            </div>
            <div class="ml-3">
              <p class="text-sm text-blue-700">请输入VS Code插件市场的完整链接，例如：<code class="bg-white px-1 py-0.5 rounded">https://marketplace.visualstudio.com/items?itemName=Vue.volar</code></p>
            </div>
          </div>
        </div>

        <!-- URL输入 -->
        <div class="mb-6">
          <label
            for="pluginUrl"
            class="block text-sm font-medium text-gray-700 mb-2"
            >Plugin Link <span class="text-red-500">*</span></label
          >
          <input
            type="text"
            id="pluginUrl"
            v-model="pluginUrl"
            class="w-full rounded-lg border border-gray-300 px-4 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            placeholder="https://marketplace.visualstudio.com/items?itemName=Vue.volar"
          />
          <p class="text-gray-500 text-xs mt-1">
            Input the plugin link, and the system will automatically extract the publisher, plugin name and version information
          </p>
        </div>

        <button
          @click="generateLinks"
          :disabled="isLoading"
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:bg-gray-400 text-white px-6 py-3 rounded-lg transition-colors font-medium"
        >
          <i :class="isLoading ? 'fas fa-spinner fa-spin' : 'fas fa-link'" class="mr-2"></i>
          {{ isLoading ? 'Getting plugin information...' : 'Generate download link' }}
        </button>
      </div>

      <!-- 结果区域 - 默认显示并留白 -->
      <div class="fade-in result-container">
        <!-- 平台无关链接 -->
        <div class="bg-white rounded-xl shadow-md p-6 mb-6 card-hover">
          <h2
            class="text-xl font-semibold text-gray-800 mb-4 flex items-center"
          >
            <i class="fas fa-globe text-indigo-500 mr-2"></i>Download Link 1 (Platform Independent)
          </h2>
          <div class="flex">
            <input
              type="text"
              :value="platformIndependentLink"
              class="flex-1 rounded-l-lg border border-gray-300 px-4 py-3 bg-gray-50 text-gray-700"
              readonly
              placeholder="请输入插件链接并点击生成按钮获取下载链接"
            />
            <button
              @click="copyToClipboard(platformIndependentLink)"
              class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-3 rounded-r-lg transition-colors"
              :disabled="!platformIndependentLink"
            >
              <i class="fas fa-copy mr-2"></i>Copy
            </button>
          </div>
        </div>

        <!-- 平台相关链接 - 依次展示所有平台 -->
        <div class="bg-white rounded-xl shadow-md p-6 card-hover">
          <h2
            class="text-xl font-semibold text-gray-800 mb-4 flex items-center"
          >
            <i class="fas fa-desktop text-indigo-500 mr-2"></i>Download Link 2 (Platform Dependent)
          </h2>
          <div v-for="platform in platforms" :key="platform" class="flex mb-4 last:mb-0">
            <input
              type="text"
              :value="generatePlatformDependentLink(platform)"
              class="flex-1 rounded-l-lg border border-gray-300 px-4 py-3 bg-gray-50 text-gray-700"
              readonly
              :placeholder="`${platform}平台下载链接将在此显示`"
            />
            <button
              @click="copyToClipboard(generatePlatformDependentLink(platform))"
              class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-3 rounded-r-lg transition-colors"
              :disabled="!platformIndependentLink"
            >
              <i class="fas fa-copy mr-2"></i>Copy
            </button>
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
            'toast px-4 py-2 rounded-lg shadow-lg mb-2 flex items-center',
            toastType === 'error' ? 'bg-red-500 text-white' : 'bg-green-500 text-white'
          ]"
        >
          <i :class="toastType === 'error' ? 'fas fa-exclamation-circle' : 'fas fa-check-circle'" class="mr-2"></i>
          {{ toastMessage }}
        </div>
      </div>
    </div>

    <footer class="bg-gray-100 py-4 mt-8">
      <div class="container mx-auto px-4 text-center text-gray-500 text-sm">
        <p>TvT</p>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      pluginUrl: '',
      isLoading: false,
      platformIndependentLink: '',
      // 预设常见平台列表
      platforms: ['win32-x64', 'linux-x64', 'darwin-x64', 'darwin-arm64'],
      toastMessage: '',
      toastType: 'success'
    }
  },
  methods: {
    async generateLinks() {
      if (!this.pluginUrl.trim()) {
        this.showToast('Please input the plugin link', 'error')
        return
      }

      this.isLoading = true

      try {
        // 调用后端API
        const response = await fetch('/extract-data', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ url: this.pluginUrl }),
        })

        if (!response.ok) {
          const errorData = await response.json()
          throw new Error(errorData.detail || 'Failed to get plugin information')
        }

        const data = await response.json()

        if (!data.publisher || !data.unique_identifier || !data.version) {
          throw new Error('Failed to extract complete plugin information from the link')
        }

        // 生成平台无关链接
        this.platformIndependentLink = `https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${encodeURIComponent(
          data.publisher
        )}/vsextensions/${encodeURIComponent(
          data.unique_identifier
        )}/${encodeURIComponent(data.version)}/vspackage`

        this.showToast('插件信息获取成功，已生成下载链接')
      } catch (error) {
        console.error('Error:', error)
        this.showToast(error.message || '获取插件信息时发生错误', 'error')
      } finally {
        this.isLoading = false
      }
    },

    generatePlatformDependentLink(platform) {
      if (!this.platformIndependentLink) return ''
      
      // 从平台无关链接中提取基础信息
      const baseUrl = this.platformIndependentLink.split('/vspackage')[0]
      return `${baseUrl}?targetPlatform=${encodeURIComponent(platform)}`
    },

    copyToClipboard(text) {
      if (!text) return
      
      navigator.clipboard.writeText(text).then(() => {
        this.showToast('链接已成功复制到剪贴板')
      }).catch(() => {
        // 降级方案
        const textArea = document.createElement('textarea')
        textArea.value = text
        document.body.appendChild(textArea)
        textArea.select()
        document.execCommand('copy')
        document.body.removeChild(textArea)
        this.showToast('链接已成功复制到剪贴板')
      })
    },

    showToast(message, type = 'success') {
      this.toastMessage = message
      this.toastType = type
      setTimeout(() => {
        this.toastMessage = ''
      }, 3000)
    }
  }
}
</script>