from fastapi import FastAPI
import subprocess
import json
from pydantic import BaseModel


app = FastAPI()


class LinkedinTask(BaseModel):
    typeoftask: str
    name: str

@app.post('/scrap', status_code=201)
def addTask( task: LinkedinTask):
    """
    curl -v -X POST http://127.0.0.1:5057/scrap -d '{"typeoftask": "username", "name": "austinoboyle"}'
    """

    if task.typeoftask == "username":
        p = subprocess.run(['scrapeli', '--headless', '--user', task.name, '--output_file', '/linkedin/output.json'], stdout=subprocess.PIPE)
    elif task.typeoftask == "userurl":
        p = subprocess.run(['scrapeli', '--headless', '--url', task.name, '--output_file', '/linkedin/output.json'], stdout=subprocess.PIPE)
    elif task.typeoftask == "compagnyname":
        return {"error": "not implemented yet"}
    elif task.typeoftask == "help":
        return {
            "username"  :   "scrap the linkedin profile given a username",
            "userurl"   :  "scrap the linkedin profile given a url"
            }
    else:
        return {"error":"Task not understood"}
    
    with open('/linkedin/output.json') as json_file:
        data = json.load(json_file)
        return data

