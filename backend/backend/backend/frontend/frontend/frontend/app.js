document.getElementById("loginBtn").onclick = async () => {
    const scopes = ["username", "payments"];

    const auth = await Pi.authenticate(scopes, onIncompletePaymentFound);

    document.getElementById("status").innerText = "Login Successful!";
    document.getElementById("dashboard").style.display = "block";
    document.getElementById("username").innerText = auth.user.username;
};

// ---------------------------
// TASK COMPLETION
// ---------------------------

function completeTask(amount) {
    alert(`Task Completed! You earned ${amount} Pi`);
}

// ---------------------------
// PAYMENT
// ---------------------------

async function startPayment() {
  const payment = await Pi.createPayment({
    amount: 1,
    memo: "User donation",
    metadata: { purpose: "donation" }
  });

  console.log("Payment started:", payment);
}

function onIncompletePaymentFound(payment) {
  console.log("Incomplete payment:", payment);
}
