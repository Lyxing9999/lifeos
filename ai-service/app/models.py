from pydantic import BaseModel, Field
from typing import Optional


class AiSummaryRequest(BaseModel):
    date: str = Field(..., examples=["2026-04-18"])
    timezone: str = Field(..., examples=["Asia/Phnom_Penh"])
    topPlaceName: str = Field(..., examples=["Home"])
    topPlaceDurationMinutes: int = Field(..., ge=0)
    totalTasks: int = Field(..., ge=0)
    completedTasks: int = Field(..., ge=0)
    totalPlannedBlocks: int = Field(..., ge=0)
    totalStaySessions: int = Field(..., ge=0)
    completionScore: int = Field(..., ge=0, le=100)
    structureScore: int = Field(..., ge=0, le=100)
    overallScore: int = Field(..., ge=0, le=100)


class AiSummaryResult(BaseModel):
    summaryText: str
    scoreExplanation: str
    insight: str
    fallbackUsed: bool
    model: Optional[str] = None