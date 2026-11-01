(() => {
 const cfg=window.BLACKSTORE_SUPABASE||{};
 const el=id=>document.getElementById(id);
 const msg=s=>{el('adminMessage').textContent=s};
 let token=null;
 const endpoint=`${cfg.url}/auth/v1`;
 async function api(path,options={}){
  const res=await fetch(`${cfg.url}${path}`,{...options,headers:{apikey:cfg.anonKey,...(token?{Authorization:`Bearer ${token}`} :{}),'Content-Type':'application/json',...(options.headers||{})}});
  const data=await res.json().catch(()=>null);
  if(!res.ok)throw Error(data?.msg||data?.error_description||data?.message||`HTTP ${res.status}`);
  return data;
 }
 function node(tag,text){const e=document.createElement(tag);e.textContent=text??'';return e}
 async function load(){
  const data=await api('/rest/v1/rpc/admin_list_vendor_applications',{method:'POST',body:'{}'});
  const wrap=el('adminApplications');wrap.replaceChildren();
  if(!Array.isArray(data)||!data.length){wrap.append(node('p','No hay solicitudes.'));return}
  for(const a of data){
   const card=node('article');card.className='admin-application';
   for(const [label,key] of [['Negocio','business_name'],['Contacto','contact_name'],['Ciudad','city'],['WhatsApp','whatsapp'],['Categoría','category'],['Descripción','description'],['Estado','status']])card.append(node('p',`${label}: ${a[key]??''}`));
   if(a.status==='approved'){
    const input=node('input');input.type='email';input.placeholder='Correo registrado del vendedor';input.setAttribute('aria-label','Correo del vendedor');
    const activate=node('button','Activar tienda');activate.type='button';activate.onclick=async()=>{if(!input.value.trim())return msg('Escribe el correo del vendedor.');activate.disabled=true;try{await api('/rest/v1/rpc/admin_activate_store',{method:'POST',body:JSON.stringify({p_application_id:a.id,p_vendor_email:input.value.trim()})});msg('Tienda activada. El vendedor ya puede entrar.')}catch(e){msg('No se pudo activar: '+e.message)}finally{activate.disabled=false}};card.append(input,activate);
   }
   if(a.status==='pending')for(const [label,status] of [['Aprobar','approved'],['Rechazar','rejected']]){
    const b=node('button',label);b.type='button';if(status==='rejected')b.className='reject';
    b.onclick=async()=>{if(!confirm(`${label} la solicitud de ${a.business_name}?`))return;b.disabled=true;try{await api('/rest/v1/rpc/admin_review_vendor_application',{method:'POST',body:JSON.stringify({p_application_id:a.id,p_new_status:status})});msg('Solicitud actualizada.');await load()}catch(e){msg('Error: '+e.message);b.disabled=false}};card.append(b)
   }
   wrap.append(card)
  }
 }
 function loggedOut(){token=null;el('adminLogin').hidden=false;el('adminPanel').hidden=true;el('adminPassword').value=''}
 el('adminLoginForm').addEventListener('submit',async e=>{
  e.preventDefault();msg('Verificando acceso...');
  try{
   const result=await api('/auth/v1/token?grant_type=password',{method:'POST',body:JSON.stringify({email:el('adminEmail').value.trim(),password:el('adminPassword').value})});
   token=result.access_token;
   await load();el('adminLogin').hidden=true;el('adminPanel').hidden=false;el('adminIdentity').textContent='Sesión: '+result.user.email;msg('Acceso autorizado.');
  }catch(err){loggedOut();msg('No se pudo iniciar sesión o la cuenta no tiene permisos de administración: '+err.message)}
 });
 el('adminRefresh').onclick=()=>load().catch(e=>msg('Error: '+e.message));
 el('adminLogout').onclick=async()=>{try{await api('/auth/v1/logout',{method:'POST'})}catch(e){}loggedOut();msg('Sesión cerrada.')};
})();
