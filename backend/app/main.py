from fastapi import FastAPI

app = FastAPI(
    title="Ayusync Backend API",
    description="Core backend for the Ayusync Autonomous Care Coordination System",
    version="0.1.0"
)

@app.get("/")
async def root():
    return {"status": "ok", "message": "Ayusync Backend is running"}

@app.get("/health")
async def health_check():
    # TODO: Add database and EventBridge connection checks here
    return {"status": "healthy"}
