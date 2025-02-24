const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const os = require('os'); // added for temporary directory
const { whisper } = require("whisper-node");
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
        
        const options = {
            modelName: "base",
            whisperOptions: {
                language: 'auto',
                gen_file_txt: false,
            }
        };

        // Process audio file with whisper
        const transcript = await whisper(tempFilePath, options);
        if (!transcript || !Array.isArray(transcript)) {
            return res.status(500).json({ error: "'base.en' model not found! Run 'npx whisper-node download base.en'" });
        }
        const transcriptStr = transcript.map(item => item.speech).join(' ');

        // Directly send the transcript as JSON response
        res.json({ transcription: transcriptStr });

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