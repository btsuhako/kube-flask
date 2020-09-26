FROM python:3.8.5-slim

RUN apt-get update && \
    apt-get install postgresql-client-11 postgresql-common libpq-dev build-essential -yq --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ./app/requirements.txt .

RUN pip install -r requirements.txt

COPY ./app ./

CMD ["python", "/app/app.py"]
