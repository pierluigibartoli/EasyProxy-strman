FROM python:3.11-bookworm

# Imposta la directory di lavoro
WORKDIR /app

# Installa FFmpeg
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Copia e installa le dipendenze Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia tutto il resto del codice
COPY . .

# --- SOLUZIONE PER L'ERRORE DI PERMESSI ---
# Creiamo la cartella che l'app vuole usare e diamo i permessi all'utente 1000
RUN mkdir -p /app/temp_hls && chmod 777 /app/temp_hls

# Configurazione porta Hugging Face
ENV PORT=7860
EXPOSE 7860

# Creazione utente Hugging Face (UID 1000 è lo standard HF)
RUN useradd -m -u 1000 user
# Assicuriamoci che l'utente 'user' possieda la cartella /app
RUN chown -R user:user /app

USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Avvio con gunicorn
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:7860 --workers 2 --worker-class aiohttp.worker.GunicornWebWorker --timeout 120 --graceful-timeout 120 app:app"]
