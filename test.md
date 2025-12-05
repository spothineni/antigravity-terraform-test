
# ✅ **1. Databricks + Spark Code Comparison Prompt**

**Prompt:**

> Compare both models by generating Spark code and explaining logic.
>
> **Task:**
> Write a PySpark job that:
>
> * Reads JSON logs from S3
> * Extracts all rows where `status == "ERROR"`
> * Aggregates counts per `service`
> * Writes results as Delta table partitioned by `date`
> * Adds schema enforcement and auto-loader semantics
>
> Output required from each model:
>
> 1. Full PySpark code
> 2. Error handling
> 3. Performance optimizations
> 4. Explanation of why each step is needed
> 5. Identify any missing/mistaken assumptions

---

# ✅ **2. AWS Lambda + Bedrock + OpenSearch Integration Prompt**

**Prompt:**

> Evaluate coding accuracy for AWS Bedrock + OpenSearch + Lambda.
>
> **Task:**
> Write a Python Lambda function that:
>
> * Takes a query from API Gateway
> * Calls Bedrock `InvokeModel` with embeddings
> * Queries OpenSearch vector index using KNN search
> * Returns top 3 chunks
> * Includes IAM permissions, retries, boto3 error handling
>
> Compare:
>
> * Correct use of boto3/bedrock-runtime client
> * Correct OpenSearch KNN query syntax
> * Valid IAM actions
> * No hallucinated APIs

This test shows **if Windsurf model hallucinates unsupported Bedrock APIs**, while Claude usually stays accurate.

---

# ✅ **3. Terraform Infra Generation Prompt**

**Prompt:**

> Compare IaC generation quality.
>
> **Task:**
> Write Terraform that provisions:
>
> * An EKS cluster
> * Managed node groups (2 node groups)
> * IRSA role for a pod
> * VPC with public+private subnets
> * An ALB ingress controller with Helm
>
> Requirements:
>
> * Correct providers
> * No deprecated arguments
> * Modules vs resources clarity
> * Output variables
> * Inline comments
>
> Score each model on correctness & hallucination.

Claude usually produces correct Terraform; some self-hosted models hallucinate outdated syntax.

---

# ✅ **4. Debugging & Fixing Code Prompt**

**Prompt:**

> Test debugging skill and hallucination control.
>
> **Task:**
> Given this buggy Python code (paste your own):
>
> ```python
> client = boto3.client("bedrock")
> response = client.invoke(modelId="anthropic.claude-3-sonnet", input=payload)
> print(response["body"]["result"])
> ```
>
> Fix the code and explain:
>
> 1. All errors
> 2. Correct Bedrock client naming (`bedrock-runtime`)
> 3. Correct streaming vs non-streaming API
> 4. Correct reading of response body
>
> Compare how each model explains the fix and whether it invents wrong parameters.

---

# ✅ **5. Create a Local RAG Pipeline Prompt (Advanced Code Comparison)**

**Prompt:**

> Compare ability to write multi-component systems.
>
> **Task:**
> Write complete code to build a local RAG pipeline:
>
> * Chunk PDF using PyPDF
> * Create sentence embeddings (use HuggingFace embed model)
> * Store in FAISS index
> * Query index
> * Combine top chunks and call LLM for answer (abstract LLM call)
>
> Deliverables:
>
> * Full Python code (no placeholders)
> * Modular functions
> * Explain vector dimensions, normalization, tuning parameters
> * Don’t hallucinate FAISS features
>
> Compare modularity, correctness, hallucination.

---

# ✅ **6. Performance Optimization Prompt**

**Prompt:**

> Evaluate optimization ability.
>
> **Task:**
> Take this naive Python code:
>
> ```python
> results = []
> for row in rows:
>     if "ERROR" in row["message"]:
>         results.append(row)
> ```
>
> Optimize for speed when `rows` contains 30M log entries.
>
> Models should propose improvements:
>
> * Vectorization
> * Multiprocessing
> * Chunked S3 streaming
> * PySpark rewrite
>
> Compare realism of suggestions.

---

# ✅ **7. RAG Metadata Filtering Prompt (OpenSearch)**

**Prompt:**

> Validate correctness of OpenSearch queries + embeddings.
>
> **Task:**
> Write an OpenSearch DSL query to:
>
> * Perform vector similarity search
> * Filter chunks by `tenant_id = "acme"`
> * Filter by `created_at > now-7d`
> * Use `approximate k-NN`
>
> Compare:
>
> * Proper syntax for `knn`
> * Missing vs correct nesting
> * Whether models hallucinate unsupported operators

---

# ✅ **8. Generate a Full CI/CD Pipeline Prompt**

**Prompt:**

> Compare ability to produce correct pipeline YAML.
>
> **Task:**
> Create GitLab CI/CD YAML that:
>
> * Builds Docker image
> * Runs tests
> * Deploys to EKS using kubectl
> * Pulls image from ECR
> * Uses OIDC for authentication
>
> Compare correctness of:
>
> * YAML structure
> * AWS auth
> * kubectl commands
> * ECR login steps

---

# ✅ **9. Multi-File Codebase Prompt**

This exposes **hallucination + architecture** differences.

**Prompt:**

> Generate a 3-file microservice in Python:
>
> * `main.py` – FastAPI endpoints
> * `llm_service.py` – Interacts with Bedrock or local model
> * `vector_store.py` – Handles FAISS ops
>
> Requirements:
>
> * Dependency injection
> * Pydantic models
> * Async FastAPI
> * Complete working code
>
> Compare which model generates runnable code and which misses imports.

---

# Want me to generate **automated scoring prompts** or **side-by-side evaluator scripts**?

I can generate:

✔ A JSON evaluation schema
✔ A Python evaluator that sends prompts to both models and compares outputs
✔ A Windsurf test harness for batch evaluation
✔ A scoring rubric for correctness, hallucination, stability

Just tell me:

**→ Which self-hosted model you’re running (LLama 3.1? Mistral? Qwen? Custom LoRA?)**
