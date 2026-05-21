from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.testclient import TestClient

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Hello World"}

client = TestClient(app)
response = client.get("/", headers={"Origin": "http://localhost:3000"})
print("With allow_origins=['http://localhost:*']: ", response.headers.get("access-control-allow-origin"))

app2 = FastAPI()
app2.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://localhost:.*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
client2 = TestClient(app2)
response2 = client2.get("/", headers={"Origin": "http://localhost:3000"})
print("With allow_origin_regex: ", response2.headers.get("access-control-allow-origin"))
