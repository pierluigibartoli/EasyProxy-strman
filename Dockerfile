FROM python:3.11-bookworm

WORKDIR /app

# Installazione dipendenze di sistema
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Copia e installa dipendenze Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia il resto del codice
COPY . .

# --- MODIFICA FONDAMENTALE PER HUGGING FACE ---
# Forziamo la porta a 7860 che è l'unica aperta su HF
ENV PORT=7860
EXPOSE 7860

# Crea un utente non-root (opzionale ma consigliato per evitare blocchi di sicurezza)
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Comando di avvio corretto per Hugging Face
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:7860 --workers 2 --worker-class aiohttp.worker.GunicornWebWorker --timeout 120 --graceful-timeout 120 app:app"]
