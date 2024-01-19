import os
from fastapi import FastAPI, HTTPException
from typing import List
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

from langchain_community.document_loaders import PyPDFLoader
from langchain_openai import OpenAIEmbeddings
from langchain_openai import OpenAI
from langchain_community.vectorstores.faiss import FAISS
from langchain.chains.question_answering import load_qa_chain
from langchain.chains import ConversationalRetrievalChain


app = FastAPI()


origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set OpenAI API key
os.environ["OPENAI_API_KEY"] = "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"

# Load PDF and create chunks
loader = PyPDFLoader("C:/Users/RACHAD/PycharmProjects/Lab_DL/Lab3/doc/Decision-Tree.pdf")
chunks = loader.load_and_split()

# Create vector database
embeddings = OpenAIEmbeddings()
db = FAISS.from_documents(chunks, embeddings)

# Create QA chain
chain = load_qa_chain(OpenAI(temperature=0), chain_type="stuff")

# Create conversation chain
qa = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0.1), db.as_retriever())
chat_history = []

# Set the initial question
initial_query = "Who created ?"

# Add the initial question to chat_history
chat_history.append((initial_query, ""))


class ChatInput(BaseModel):
    user_input: str


class ChatOutput(BaseModel):
    chatbot_response: str
    chat_history: List


@app.post("/chatbot/", response_model=ChatOutput)
async def get_chatbot_response(chat_input: ChatInput):
    try:
        # Get user input from request
        user_input = chat_input.user_input

        if user_input.lower() == 'exit':
            return {"chatbot_response": "Thank you for using the Transformers chatbot!", "chat_history": chat_history}

        # Add the user question to chat_history
        chat_history.append((user_input, ""))

        # Get the response from the chatbot
        result = qa({"question": user_input, "chat_history": chat_history})
        chat_history[-1] = (user_input, result['answer'])  # Update the last entry in chat_history with the actual answer

        return {"chatbot_response": result['answer'], "chat_history": chat_history}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error querying chatbot: {str(e)}")