import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import dotenv from "dotenv";
import fetch from "node-fetch";

dotenv.config();
const app = express();

app.use(cors());
app.use(bodyParser.json());

// -----------------------------
// PI SERVER SDK
// -----------------------------

const PI_API_URL = "https://api.minepi.com";
const PI_API_KEY = process.env.PI_API_KEY;

// verify user authentication token
app.post("/api/verify-user", async (req, res) => {
  try {
    const { piToken } = req.body;

    const response = await fetch(`${PI_API_URL}/v2/me`, {
      headers: {
        Authorization: `Bearer ${piToken}`,
        "Content-Type": "application/json",
      },
    });

    const user = await response.json();
    res.json({ success: true, user });
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

// -----------------------------
// CREATE PAYMENT
// -----------------------------
app.post("/api/create-payment", async (req, res) => {
  try {
    const { amount, memo, userUid } = req.body;

    const payment = {
      amount,
      memo,
      metadata: { userUid },
    };

    res.json({ success: true, payment });
  } catch (err) {
    res.json({ success: false, error: err.message });
  }
});

// -----------------------------
// COMPLETE PAYMENT
// -----------------------------
app.post("/api/complete-payment", (req, res) => {
  const { txid } = req.body;
  res.json({ success: true, message: "Payment completed!", txid });
});

// -----------------------------
// PORT START
// -----------------------------
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Backend running on port ${PORT}`));
