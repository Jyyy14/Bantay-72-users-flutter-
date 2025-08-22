const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure mail transport (using Mailjet, Gmail, etc.)
const transporter = nodemailer.createTransport({
  service: "gmail", // or Mailjet SMTP
  auth: {
    user: "bantay0072@gmail.com",
    pass: "rwzu rwjz vlag nwit",
    // ", // not your normal Gmail password!
  },
});

exports.sendVerificationEmail = functions.https.onCall(
  async (data, context) => {
    const { email } = data;

    // Generate a custom verification link manually
    const actionCodeSettings = {
      url: `https://Bantay72.web.app/verify?email=${email}`,
      handleCodeInApp: true,
    };

    const link = await admin
      .auth()
      .generateEmailVerificationLink(email, actionCodeSettings);

    const mailOptions = {
      from: "Bantay 72 <bantay0072@gmail.com>",
      to: email,
      subject: "Verify your email for Bantay 72",
      html: `
      <p>Hi, please verify your email by clicking the link below:</p>
      <a href="${link}">Verify Email</a>
    `,
    };

    await transporter.sendMail(mailOptions);
    return { success: true };
  }
);
