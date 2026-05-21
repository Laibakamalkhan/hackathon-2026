# Google Antigravity SDK Integration

## 1. Official Package Information
- **Package Name**: `google-antigravity`
- **Install Command**: `pip install google-antigravity`
- **Documentation/Origin**: The name "Antigravity" is a reference to the Python easter egg `import antigravity` and Google's "Chrome Experiments". It provides a terminal-first, lightweight Python library for building autonomous, code-executing agents with a stateful loop in as little as 20 lines of code.

### Minimal Agent Example
```python
import antigravity as antigrav

# Define a tool
def my_tool(input_data: str) -> str:
    return f"Processed: {input_data}"

# Initialize and run agent
agent = antigrav.Agent(
    model="gemini-2.5-flash",
    system_prompt="You are a helpful assistant.",
    tools=[my_tool]
)

response = agent.run("Please process this input")
print(response)
```

## 2. Mapping Existing Agents to Antigravity Nodes

To implement the Antigravity workflow, we map our existing agents into Antigravity tasks (nodes):

| Existing Agent / Responsibility | Antigravity Workflow Node |
| :--- | :--- |
| **CoordinatorAgent**<br>- Understands user needs<br>- Finds best providers<br>- Gets price quote<br>- Confirms with user | **Node: Coordinate**<br>Executes `understand_request_tool`, `search_providers_tool`, and `generate_price_quote_tool`. Emits trace events and transitions to Executor upon user confirmation. |
| **ExecutorAgent**<br>- Validates booking slot<br>- Creates booking<br>- Schedules reminders<br>- Handles provider cancellation | **Node: Execute**<br>Takes AgentHandoff payload. Executes `validate_slot_tool`, `create_booking_tool`. Atomically updates Firestore with booking, agent trace, and handles conflicts. |
| **GuardianAgent**<br>- Collects user feedback<br>- Resolves disputes<br>- Computes refunds<br>- Updates provider reputation | **Node: Guard/Resolve**<br>Executes `compute_refund_amount_tool`, `update_provider_reputation_tool`. Applies fairness principle and flags escalations for human review. |
