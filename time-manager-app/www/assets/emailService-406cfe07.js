class c{constructor(t=0,r="Network Error"){this.status=t,this.text=r}}const H=()=>{if(!(typeof localStorage>"u"))return{get:e=>Promise.resolve(localStorage.getItem(e)),set:(e,t)=>Promise.resolve(localStorage.setItem(e,t)),remove:e=>Promise.resolve(localStorage.removeItem(e))}},s={origin:"https://api.emailjs.com",blockHeadless:!1,storageProvider:H()},y=e=>e?typeof e=="string"?{publicKey:e}:e.toString()==="[object Object]"?e:{}:{},M=(e,t="https://api.emailjs.com")=>{if(!e)return;const r=y(e);s.publicKey=r.publicKey,s.blockHeadless=r.blockHeadless,s.storageProvider=r.storageProvider,s.blockList=r.blockList,s.limitRate=r.limitRate,s.origin=r.origin||t},w=async(e,t,r={})=>{const o=await fetch(s.origin+e,{method:"POST",headers:r,body:t}),a=await o.text(),i=new c(o.status,a);if(o.ok)return i;throw i},E=(e,t,r)=>{if(!e||typeof e!="string")throw"The public key is required. Visit https://dashboard.emailjs.com/admin/account";if(!t||typeof t!="string")throw"The service ID is required. Visit https://dashboard.emailjs.com/admin";if(!r||typeof r!="string")throw"The template ID is required. Visit https://dashboard.emailjs.com/admin/templates"},C=e=>{if(e&&e.toString()!=="[object Object]")throw"The template params have to be the object. Visit https://www.emailjs.com/docs/sdk/send/"},v=e=>e.webdriver||!e.languages||e.languages.length===0,S=()=>new c(451,"Unavailable For Headless Browser"),D=(e,t)=>{if(!Array.isArray(e))throw"The BlockList list has to be an array";if(typeof t!="string")throw"The BlockList watchVariable has to be a string"},K=e=>{var t;return!((t=e.list)!=null&&t.length)||!e.watchVariable},V=(e,t)=>e instanceof FormData?e.get(t):e[t],j=(e,t)=>{if(K(e))return!1;D(e.list,e.watchVariable);const r=V(t,e.watchVariable);return typeof r!="string"?!1:e.list.includes(r)},R=()=>new c(403,"Forbidden"),B=(e,t)=>{if(typeof e!="number"||e<0)throw"The LimitRate throttle has to be a positive number";if(t&&typeof t!="string")throw"The LimitRate ID has to be a non-empty string"},F=async(e,t,r)=>{const o=Number(await r.get(e)||0);return t-Date.now()+o},L=async(e,t,r)=>{if(!t.throttle||!r)return!1;B(t.throttle,t.id);const o=t.id||e;return await F(o,t.throttle,r)>0?!0:(await r.set(o,Date.now().toString()),!1)},P=()=>new c(429,"Too Many Requests"),x=async(e,t,r,o)=>{const a=y(o),i=a.publicKey||s.publicKey,m=a.blockHeadless||s.blockHeadless,d=a.storageProvider||s.storageProvider,u={...s.blockList,...a.blockList},_={...s.limitRate,...a.limitRate};return m&&v(navigator)?Promise.reject(S()):(E(i,e,t),C(r),r&&j(u,r)?Promise.reject(R()):await L(location.pathname,_,d)?Promise.reject(P()):w("/api/v1.0/email/send",JSON.stringify({lib_version:"4.4.1",user_id:i,service_id:e,template_id:t,template_params:r}),{"Content-type":"application/json"}))},W=e=>{if(!e||e.nodeName!=="FORM")throw"The 3rd parameter is expected to be the HTML form element or the style selector of the form"},$=e=>typeof e=="string"?document.querySelector(e):e,J=async(e,t,r,o)=>{const a=y(o),i=a.publicKey||s.publicKey,m=a.blockHeadless||s.blockHeadless,d=s.storageProvider||a.storageProvider,u={...s.blockList,...a.blockList},_={...s.limitRate,...a.limitRate};if(m&&v(navigator))return Promise.reject(S());const h=$(r);E(i,e,t),W(h);const n=new FormData(h);return j(u,n)?Promise.reject(R()):await L(location.pathname,_,d)?Promise.reject(P()):(n.append("lib_version","4.4.1"),n.append("service_id",e),n.append("template_id",t),n.append("user_id",i),w("/api/v1.0/email/send-form",n))},O={init:M,send:x,sendForm:J,EmailJSResponseStatus:c},b="service_gicc3hx",g="template_l18w0z9",A="BjiaRWJKq6l2aHrTa";O.init(A);const p={subject:"⏰ Time to Clock Out - Work Day Ended",body:`
Dear {{user_name}},

Your scheduled work hours have ended at {{end_time}}.

We noticed that you haven't clocked out yet. Please take a moment to:
1. Click the "Work End" button to clock out
2. Or use the Clock Out button in the system

**Work Summary for Today:**
- Scheduled Start: {{scheduled_start}}
- Scheduled End: {{scheduled_end}}
- Status: Still Clocked In

If you have already left, please clock out remotely or contact your manager.

Thank you for your hard work today!

Best regards,
Time Management System
  `.trim()},k={subject:"🌅 Early Arrival Recorded",body:`
Dear {{user_name}},

Your early arrival has been recorded.

**Details:**
- Scheduled Start: {{scheduled_start}}
- Actual Start: {{actual_start}}
- Early by: {{early_minutes}} minutes
- Reason: {{reason}}

Your timesheet has been updated accordingly.

Best regards,
Time Management System
  `.trim()},f={subject:"⏱️ Overtime Hours Recorded",body:`
Dear {{user_name}},

You have worked overtime today.

**Work Summary:**
- Total Hours Worked: {{total_hours}}
- Regular Hours: 8:00
- Overtime Hours: {{overtime_hours}}
- Work Start: {{work_start}}
- Work End: {{work_end}}

Your overtime will be reflected in your timesheet.

Thank you for your dedication!

Best regards,
Time Management System
  `.trim()},T={subject:"⚠️ Clock Out Reminder - Action Required",body:`
Dear {{user_name}},

IMPORTANT: You forgot to clock out today.

**Work Session:**
- Clock In Time: {{clock_in_time}}
- Expected Clock Out: {{expected_clock_out}}
- Current Time: {{current_time}}

Please log in to the system and clock out immediately to record your accurate work hours.

If you have any issues, please contact your manager or HR department.

Best regards,
Time Management System
  `.trim()},l=async e=>{try{console.log("📧 Attempting to send email to:",e.to_email),console.log("📧 Email subject:",e.subject),console.log("📧 Using EmailJS Service ID:",b),console.log("📧 Using EmailJS Template ID:",g),console.log("📧 Using EmailJS Public Key:",A);const t={to_email:e.to_email,to_name:e.to_name,subject:e.subject,message:e.message,from_name:"Time Management System",reply_to:"noreply@timemanager.com"};console.log("📧 Template parameters:",t);const r=await O.send(b,g,t);return console.log("✅ Email sent successfully:",r),alert(`✅ Email notification sent to ${e.to_email}`),{success:!0,response:r}}catch(t){return console.error("❌ Failed to send email:",t),console.error("❌ Error details:",{message:t.text||t.message,status:t.status,name:t.name,stack:t.stack}),alert(`⚠️ Email notification failed: ${t.text||t.message||"Unknown error"}

Please check console for details.`),{success:!1,error:t}}},I=async(e,t)=>{const r=p.body.replace("{{user_name}}",e.first_name).replace("{{end_time}}",t.end_time).replace("{{scheduled_start}}",t.scheduled_start).replace("{{scheduled_end}}",t.scheduled_end);return l({to_email:e.email,to_name:`${e.first_name} ${e.last_name}`,subject:p.subject,message:r})},U=async(e,t)=>{const r=k.body.replace("{{user_name}}",e.first_name).replace("{{scheduled_start}}",t.scheduled_start).replace("{{actual_start}}",t.actual_start).replace("{{early_minutes}}",t.early_minutes).replace("{{reason}}",t.reason);return l({to_email:e.email,to_name:`${e.first_name} ${e.last_name}`,subject:k.subject,message:r})},Y=async(e,t)=>{const r=f.body.replace("{{user_name}}",e.first_name).replace("{{total_hours}}",t.total_hours).replace("{{overtime_hours}}",t.overtime_hours).replace("{{work_start}}",t.work_start).replace("{{work_end}}",t.work_end);return l({to_email:e.email,to_name:`${e.first_name} ${e.last_name}`,subject:f.subject,message:r})},q=async(e,t)=>{const r=T.body.replace("{{user_name}}",e.first_name).replace("{{clock_in_time}}",t.clock_in_time).replace("{{expected_clock_out}}",t.expected_clock_out).replace("{{current_time}}",t.current_time);return l({to_email:e.email,to_name:`${e.first_name} ${e.last_name}`,subject:T.subject,message:r})},N={sendEmail:l,sendClockOutReminder:I,sendEarlyArrivalNotification:U,sendOvertimeAlert:Y,sendForgotClockOutEmail:q};export{q as a,N as e,U as s};
