from fastapi import FastAPI

from app.routes.readings import router as readings_router
from app.routes.commands import router as commands_router

app = FastAPI(
    title="ThermoSmart Backend",
    description="Backend API for thee ThermoSmart app.",
    version="1.0.0"
    )

app.include_router(readings_router)
app.include_router(commands_router)

@app.get("/")
def root():
    return{
        "message": "ThermoSmart backend is running."}
@app.get("/health")
def health_check():
    return {
        "status": "ok"
        }