from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from app.db import insert_reading, get_latest_reading, get_all_readings

router = APIRouter(prefix="/readings", tags=["readings"])


class ReadingCreate(BaseModel):
    temp: float
    humidity: float
    setpoint: Optional[float] = None


@router.post("/")
def create_reading(reading: ReadingCreate):
    try:
        saved_reading = insert_reading(
            temp=reading.temp,
            humidity=reading.humidity,
            setpoint=reading.setpoint
        )
        return {
            "message": "Reading saved successfully",
            "data": saved_reading
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save reading: {str(e)}")


@router.get("/latest")
def read_latest():
    try:
        latest_reading = get_latest_reading()

        if latest_reading is None:
            raise HTTPException(status_code=404, detail="No readings found")

        return latest_reading
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch latest reading: {str(e)}")


@router.get("/")
def read_all(limit: int = 50):
    try:
        readings = get_all_readings(limit=limit)
        return {
            "count": len(readings),
            "data": readings
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch readings: {str(e)}")
