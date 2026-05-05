import os
from fastapi import FastAPI
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer

# 1. 허깅페이스 심볼릭 링크 경고 숨기기
os.environ['HF_HUB_DISABLE_SYMLINKS_WARNING'] = '1'

app = FastAPI()

# 2. 임베딩 모델 로드 (최초 실행 시 시간이 조금 걸립니다)
# 이 모델은 텍스트 앞에 "query: " 또는 "passage: "를 붙여주는 게 성능이 더 좋습니다.
model = SentenceTransformer('intfloat/multilingual-e5-base') 

# 3. 요청 받을 데이터 형식 정의
class EmbedRequest(BaseModel):
    text: str

@app.post("/embed")
async def get_embedding(req: EmbedRequest):
    # 텍스트를 받아서 벡터 리스트로 변환
    # E5 모델의 특성상 검색 쿼리에는 "query: "를 붙이는 것이 권장됩니다.
    input_text = f"query: {req.text}" 
    vector = model.encode(input_text).tolist()
    return {"embedding": vector}

# 실행 방법: uvicorn main:app --reload