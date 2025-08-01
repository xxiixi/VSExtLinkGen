from fastapi import FastAPI, HTTPException
import requests
from bs4 import BeautifulSoup
import json
from pydantic import BaseModel
from typing import Optional

app = FastAPI(title="网页内容提取接口")

class URLRequest(BaseModel):
    url: str

class ExtractedData(BaseModel):
    version: Optional[str] = None
    publisher: Optional[str] = None
    unique_identifier: Optional[str] = None
    plugin_name: Optional[str] = None

@app.post("/extract-data", response_model=ExtractedData)
async def extract_data(request: URLRequest):
    try:
        # 发送请求获取网页内容
        response = requests.get(request.url)
        response.raise_for_status()  # 请求失败时抛出异常
        
        # 解析HTML
        soup = BeautifulSoup(response.text, "html.parser")
        
        # 查找目标标签：<div class="rhs-content"> 下的 <script class="jiContent">
        rhs_div = soup.find("div", class_="rhs-content")
        if not rhs_div:
            raise HTTPException(status_code=404, detail="未找到class为'rhs-content'的div标签")
        
        script_tag = rhs_div.find("script", class_="jiContent")
        if not script_tag:
            raise HTTPException(status_code=404, detail="未找到class为'jiContent'的script标签")
        
        # 解析script标签内的JSON数据
        try:
            json_data = json.loads(script_tag.string)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="script标签内的内容不是有效的JSON")
        
        # 提取所需信息
        extracted_data = ExtractedData()
        
        # 提取Version（从Resources字段中）
        if "Resources" in json_data and "Version" in json_data["Resources"]:
            extracted_data.version = json_data["Resources"]["Version"]
        
        # 提取Unique Identifier
        if "MoreInfo" in json_data and "UniqueIdentifierValue" in json_data["MoreInfo"]:
            extracted_data.unique_identifier = json_data["MoreInfo"]["UniqueIdentifierValue"]
            # 从Unique Identifier中提取publisher和plugin_name
            if extracted_data.unique_identifier and "." in extracted_data.unique_identifier:
                # 使用split从左边分割
                parts = extracted_data.unique_identifier.split(".", 1)
                extracted_data.publisher = parts[0]
                extracted_data.plugin_name = parts[1] if len(parts) > 1 else None
        
        return extracted_data
    
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=f"请求网页失败: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"处理数据时出错: {str(e)}")