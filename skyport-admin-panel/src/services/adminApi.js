const BASE=(import.meta.env.VITE_API_BASE_URL||'http://localhost:8080/api').replace(/\\/$/,'');
export const DEMO_MODE=import.meta.env.VITE_DEMO_MODE!=='false';
async function request(path,options={}) {
  if(DEMO_MODE) throw new Error('Demo mode is enabled. Configure the backend before using this API.');
  const response=await fetch(`${BASE}${path}`,{...options,credentials:'include',headers:{'Content-Type':'application/json',...(options.headers||{})}});
  if(!response.ok) throw new Error((await response.text().catch(()=>''))||`Request failed (${response.status})`);
  if(response.status===204)return null;
  return response.json();
}
export const adminApi={
 getDashboard:()=>request('/admin/dashboard'),
 getFlights:(query='')=>request(`/admin/flights${query?`?${query}`:''}`),
 getFlight:id=>request(`/admin/flights/${encodeURIComponent(id)}`),
 createFlight:data=>request('/admin/flights',{method:'POST',body:JSON.stringify(data)}),
 updateFlight:(id,data)=>request(`/admin/flights/${encodeURIComponent(id)}`,{method:'PUT',body:JSON.stringify(data)}),
 updateFlightStatus:(id,status)=>request(`/admin/flights/${encodeURIComponent(id)}/status`,{method:'PATCH',body:JSON.stringify({status})}),
 getAirports:()=>request('/admin/airports'),getAircraft:()=>request('/admin/aircraft'),
 getBookings:()=>request('/admin/bookings'),getPassengers:()=>request('/admin/users'),
 getTickets:()=>request('/admin/tickets'),getRevenueReport:()=>request('/admin/reports/revenue')
};
