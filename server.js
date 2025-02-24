const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const { whisper } = require("whisper-node");
const cors =require('cors')

const app = express();
const port = process.env.PORT || 4000;

app.use(cors())
app.use(express.json())

// Setup upload folder
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

// Setup transcripts folder
const transcriptDir = path.join(__dirname, 'transcripts');
if (!fs.existsSync(transcriptDir)) fs.mkdirSync(transcriptDir);

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage });

// Endpoint to get audio file and respond with transcript text file
app.post('/transcribe', upload.single('audio'), async (req, res) => {
    try {
        if (!req.file) return res.status(400).send('No file uploaded.');

        const filePath = req.file.path;
        const options = {
            modelName: "base.en",
            whisperOptions: {
                language: 'auto',
                gen_file_txt: false,
            }
        };

        // Process audio file with whisper
        const transcript = await whisper(filePath, options);
        // Convert transcript array to string if necessary
        const transcriptStr = transcript.map(item => item.speech).join(' ');

        // Directly send the transcript as JSON response instead of writing to a text file
        res.json({ transcription: transcriptStr });

        // Delete the audio file
        fs.unlink(filePath, unlinkErr => {
            if (unlinkErr) console.error("Failed to delete audio file", unlinkErr);
        });
    } catch (error) {
        console.error(error);
        res.status(500).send("Transcription failed.");
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});