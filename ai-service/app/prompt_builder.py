from app.models import AiSummaryRequest


SYSTEM_PROMPT = """
You are the LifeOS summary service.

Your job:
- Generate short, factual daily summary text.
- Use only the structured input provided.
- Do not invent facts.
- Do not add motivational fluff.
- Keep the tone grounded, calm, and practical.
- Return JSON only.

Required JSON keys:
summaryText
scoreExplanation
insight
""".strip()


def build_user_prompt(req: AiSummaryRequest) -> str:
    return f"""
Generate a grounded daily summary from this structured input.

date: {req.date}
timezone: {req.timezone}
topPlaceName: {req.topPlaceName}
topPlaceDurationMinutes: {req.topPlaceDurationMinutes}
totalTasks: {req.totalTasks}
completedTasks: {req.completedTasks}
totalPlannedBlocks: {req.totalPlannedBlocks}
totalStaySessions: {req.totalStaySessions}
completionScore: {req.completionScore}
structureScore: {req.structureScore}
overallScore: {req.overallScore}

Rules:
- summaryText must be 1-2 short sentences.
- scoreExplanation must be 1 short sentence.
- insight must be 1 short sentence.
- Do not mention information not present above.
- Keep wording practical and concise.
""".strip()