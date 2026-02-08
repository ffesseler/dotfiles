#!/bin/bash
# View promptfoo eval results in a readable format

RESULTS_FILE="results.json"

if [ ! -f "$RESULTS_FILE" ]; then
    echo "Error: $RESULTS_FILE not found. Run 'npx promptfoo eval' first."
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 GENERATED COMMIT MESSAGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
jq -r '.results.results[0].response.output' "$RESULTS_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 GRADING RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCORE=$(jq -r '.results.results[0].gradingResult.score' "$RESULTS_FILE")
PASS=$(jq -r '.results.results[0].gradingResult.pass' "$RESULTS_FILE")

if [ "$PASS" = "true" ]; then
    echo "✅ PASS - Score: $SCORE/10"
else
    echo "❌ FAIL - Score: $SCORE/10"
fi

echo ""
jq -r '.results.results[0].gradingResult.componentResults[0].reason' "$RESULTS_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 TOKEN USAGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Generation:"
jq -r '.results.results[0].response.tokenUsage | "  Total: \(.total) (cached: \(.cached))"' "$RESULTS_FILE"
echo ""
echo "Grading:"
jq -r '.results.results[0].gradingResult.tokensUsed | "  Total: \(.total) (\(.prompt) prompt + \(.completion) completion)"' "$RESULTS_FILE"
echo ""
