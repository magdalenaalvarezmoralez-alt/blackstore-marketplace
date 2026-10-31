const WHATSAPP_NUMBER = "573245097798"; // Actualiza este número si cambia el contacto comercial.
const menuToggle = document.getElementById("menuToggle");
const nav = document.getElementById("nav");
menuToggle?.addEventListener("click", () => {
  const opened = nav.classList.toggle("open");
  menuToggle.setAttribute("aria-expanded", String(opened));
  menuToggle.setAttribute("aria-label", opened ? "Cerrar menú" : "Abrir menú");
});
nav?.querySelectorAll("a").forEach(link => link.addEventListener("click", () => {
  nav.classList.remove("open");
  menuToggle?.setAttribute("aria-expanded", "false");
}));
document.getElementById("year").textContent = new Date().getFullYear();

const form = document.getElementById("sellerForm");
const feedback = document.getElementById("formFeedback");
form?.addEventListener("submit", async event => {
  event.preventDefault();
  if (!form.reportValidity()) return;
  const config = window.BLACKSTORE_SUPABASE || {};
  if (!/^https:\/\/[a-z0-9-]+\.supabase\.co$/.test(config.url || "") || !config.anonKey || config.anonKey.includes("PON_AQUI")) {
    feedback.textContent = "El registro todavía no está habilitado. Contacta a Blackstore para solicitar información.";
    return;
  }
  const data = new FormData(form);
  const button = form.querySelector('button[type="submit"]');
  button.disabled = true;
  feedback.textContent = "Enviando solicitud...";
  try {
    const response = await fetch(`${config.url}/rest/v1/rpc/submit_vendor_application`, {
      method: "POST",
      headers: { "apikey": config.anonKey, "Content-Type": "application/json" },
      body: JSON.stringify({
        p_business_name: String(data.get("business") || "").trim(),
        p_contact_name: String(data.get("contact") || "").trim(),
        p_city: String(data.get("city") || "").trim(),
        p_phone: String(data.get("phone") || "").trim(),
        p_category: String(data.get("category") || "").trim(),
        p_description: String(data.get("details") || "").trim()
      })
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    feedback.textContent = "¡Solicitud recibida! Blackstore revisará tus datos y te contactará. Esto todavía no crea una tienda ni una cuenta.";
    form.reset();
  } catch (error) {
    console.error("Error al enviar solicitud", error);
    feedback.textContent = "No se pudo guardar la solicitud. Intenta de nuevo más tarde.";
  } finally {
    button.disabled = false;
  }
});
