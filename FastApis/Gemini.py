from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google.generativeai import GenerativeModel
from IPython.display import Markdown
import textwrap
import google.generativeai as genai
import traceback

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update with your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Standard library imports
# Third-party imports


@app.get("/")
def read_root():
    return {"Hello": "World"}

class InputText(BaseModel):
    text: str

class GenerativeApi:
    def __init__(self, api_key):
        self.api_key = api_key
        self.model = GenerativeModel('gemini-pro')

    def configure(self):
        genai.configure(api_key=self.api_key)

    def generate_content(self, text):
        response = self.model.generate_content(text)
        markdown_text = response.text.replace('•', '  *')
        indented_text = textwrap.indent(markdown_text, '> ', predicate=lambda _: True)
        return Markdown(indented_text)

generative_api = GenerativeApi(api_key='AIzaSyCt5esj3hr40VCl8n9uQLf6jurqqDYcbSQ')


@app.post("/generate_content", response_class=HTMLResponse)
async def generate_content(input_text: InputText):
    try:
        generative_api.configure()
        result = generative_api.generate_content(input_text.text)

        if isinstance(result, Markdown):
            # Retrieve HTML content from the Markdown object
            html_content = result.data

            # Return the content as HTMLResponse
            return HTMLResponse(content=html_content)
        else:
            raise HTTPException(status_code=500, detail="Unexpected response format")
    except Exception as e:
        traceback.print_exc()  # Print the traceback
        raise HTTPException(status_code=500, detail=str(e))