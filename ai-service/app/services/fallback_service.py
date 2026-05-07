from app.models import AiSummaryRequest, AiSummaryResult


def generate_fallback(req: AiSummaryRequest) -> AiSummaryResult:
    summary_text = (
        f"You spent most of your detected time at {req.topPlaceName}, "
        f"completed {req.completedTasks} of {req.totalTasks} tasks, "
        f"and had {req.totalPlannedBlocks} planned blocks with "
        f"{req.totalStaySessions} stay sessions."
    )

    score_explanation = (
        f"Overall score {req.overallScore} comes from completion {req.completionScore} "
        f"and structure {req.structureScore}."
    )

    insight = (
        f"Your strongest place signal was {req.topPlaceName} "
        f"for {req.topPlaceDurationMinutes} minutes."
    )

    return AiSummaryResult(
        summaryText=summary_text,
        scoreExplanation=score_explanation,
        insight=insight,
        fallbackUsed=True,
        model=None,
    )