const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const os = require('os');
// Removed: const { whisper } = require("whisper-node");
const { execSync } = require('child_process'); // added for calling whisper.cpp
const cors = require('cors');

const app = express();
const port = process.env.PORT || 4000;

app.use(cors());
// Removed uploadDir and transcripts folder setup since we don't need to persist uploads.

// Use memory storage instead of disk storage for audio files
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Endpoint to get audio file and respond with transcript text file
app.post('/transcribe', upload.single('audio'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).send('No file uploaded.');
        
        // Write in-memory file buffer to a temporary file
        const tempFilePath = path.join(os.tmpdir(), Date.now() + '-' + req.file.originalname);
        fs.writeFileSync(tempFilePath, req.file.buffer);
        
        // Use whisper.cpp binary to perform transcription.
        const cmd = `whisper ${tempFilePath} --model ./models/ggml-base.en.bin --language auto --print`;
        const transcript = execSync(cmd, { encoding: 'utf-8' }).trim();

        // Directly send the transcript as JSON response
        res.json({ transcription: transcript });

        // Delete the temporary file
        fs.unlink(tempFilePath, unlinkErr => {
            if (unlinkErr) console.error("Failed to delete temporary file", unlinkErr);
        });
    } catch (error) {
        console.error(error);
        res.status(500).send("Transcription failed.");
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});