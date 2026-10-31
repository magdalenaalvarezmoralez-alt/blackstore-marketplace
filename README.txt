# BLACKSTORE MARKETPLACE — VERSIÓN 4.0 (ETAPA INICIAL)

Esta versión cambia el enfoque de tienda de demostración a convocatoria inicial de un marketplace afro.

## Cambios realizados
- Se retiró el catálogo ficticio con nombres y precios que podían confundirse con inventario real.
- Se retiraron el carrito y el flujo de pedido de productos inexistentes.
- Se añadieron las opciones "Quiero comprar" y "Quiero vender".
- Se muestran categorías como orientación, con aviso de que las imágenes son ilustrativas.
- Se agregó un formulario inicial de interés para vendedores.
- El formulario prepara un mensaje de WhatsApp con los datos del negocio.
- Se informa claramente que todavía no hay vendedores ni productos reales.
- Diseño adaptable a celulares y computadores.
- Se conserva el logo y parte de los recursos visuales del proyecto anterior.

## IMPORTANTE: qué hace y qué no hace esta versión
Esta es una primera etapa visual y de captación de interesados. Está pensada para poder publicarse como sitio informativo estático en GitHub Pages.

El formulario NO crea una cuenta, NO guarda solicitudes en una base de datos y NO crea tiendas. Abre WhatsApp para que el interesado envíe manualmente su solicitud al número configurado.

Todavía NO incluye:
- Base de datos ni backend.
- Registro/autenticación real de compradores o vendedores.
- Panel privado de vendedor.
- Panel de administración.
- Publicación de productos por vendedores.
- Carrito y checkout reales.
- Pagos, comisiones, desembolsos ni gestión de envíos.

Esas funciones requieren backend, base de datos, autenticación, almacenamiento seguro de imágenes e integración de una pasarela de pagos apta para marketplace. Se implementarán en fases posteriores y se probarán antes de activar ventas.

## Número de WhatsApp
En `script.js`, la variable `WHATSAPP_NUMBER` contiene `573245097798`.
Usa el formato internacional, solo números, sin + ni espacios. Cámbialo si el número comercial definitivo es otro.

## Publicar en GitHub Pages
1. Descomprime el ZIP.
2. Abre la carpeta `Blackstore-Marketplace-v4`.
3. Sube todo su contenido a la raíz del repositorio, de modo que `index.html` quede en la raíz.
4. En GitHub entra a Settings → Pages.
5. Selecciona Deploy from a branch, rama `main`, carpeta `/ (root)` y guarda.
6. Espera a que finalice la publicación.

## Próxima fase técnica recomendada
1. Crear proyecto Supabase.
2. Diseñar tablas para perfiles, tiendas, solicitudes, productos, categorías y pedidos.
3. Implementar autenticación y roles (comprador, vendedor, administrador).
4. Construir el panel de administración para revisar y aprobar vendedores.
5. Construir el panel de vendedor para cargar productos e imágenes.
6. Activar catálogo real solo con productos aprobados.
7. Integrar pagos divididos/marketplace con un proveedor que confirme soporte en Colombia, identidad de vendedores y desembolsos.
