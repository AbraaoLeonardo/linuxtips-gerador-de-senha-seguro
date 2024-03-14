FROM cgr.dev/chainguard/python:latest-dev as build
COPY requirements.txt .
RUN pip install -r requirements.txt


FROM cgr.dev/chainguard/python:latest
WORKDIR /app
COPY app.py .
COPY ./templates templates/
COPY ./static static/
COPY --from=build /home/nonroot/.local/lib/python3.12/site-packages /app
ENTRYPOINT ["python", "-m", "flask","run","--host=0.0.0.0"]
