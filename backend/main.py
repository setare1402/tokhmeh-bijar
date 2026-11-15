from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Tokhmeh Bijar API",
    description="Backend API for Tokhmeh Bijar",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "message": "Tokhmeh Bijar API is running",
        "status": "ok",
    }


@app.get("/health")
def health():
    return {"status": "healthy"}
