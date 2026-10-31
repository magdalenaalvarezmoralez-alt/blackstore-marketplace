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
form?.addEventListener("submit", event => {
  event.preventDefault();
  if (!form.reportValidity()) return;
  const data = new FormData(form);
  const fields = [
    "Hola Blackstore. Quiero solicitar información para vender en el marketplace.",
    `Negocio: ${data.get("business")}`,
    `Contacto: ${data.get("contact")}`,
    `Ciudad: ${data.get("city")}`,
    `WhatsApp: ${data.get("phone")}`,
    `Categoría: ${data.get("category")}`,
    `Descripción: ${data.get("details") || "No especificada"}`,
    "",
    "Entiendo que esta es una solicitud inicial y que mi tienda no se crea automáticamente."
  ];
  const url = `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(fields.join("\n"))}`;
  feedback.textContent = "Se abrirá WhatsApp con tu solicitud lista para enviar. Revisa el mensaje antes de enviarlo.";
  window.open(url, "_blank", "noopener,noreferrer");
});
