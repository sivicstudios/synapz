import app from "./app";
import DB from "./config/db";

const PORT = process.env.PORT || 3000;

// Connect to MongoDB
DB();

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
