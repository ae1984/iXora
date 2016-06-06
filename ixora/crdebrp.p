/* crdebrp.p
 * MODULE
        Мониторинг карточных задолжностей
 * DESCRIPTION
        Работа с задолжниками 
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        14-?
 * AUTHOR
        05.12.2005 
        tsoy
 * CHANGES
*/

{mainhead.i}

def var cats as char extent 7 initial [
    "1. Стандартные",
    "1) сомнительные 1 категории - при своевременной и полной оплате платежей",
    "2) сомнительные 2 категории - при задержке и неполной оплате платежей",
    "3) сомнительные 3 категории - при своевременной и полной оплате платежей",
    "4) сомнительные 4 категории - при задержке и неполной оплате платежей",
    "5) сомнительные 5 категории",
    "3. Безнадежные"
].

def var cat as int.


&scoped-define CONCURRCONV (if contract_curr = 840 then usdrate else 1)
&scoped-define ACCCURRCONV (if contract_curr = 840 then usdrate else 1)

def var usdrate as decimal no-undo.
def var fdate as date no-undo. 

def var sup    as deci no-undo. /* сумма обеспечения */
def var sup1   as deci no-undo. /* обеспеч. по Cl Security Deposit */
def var sup2   as deci no-undo. /* обеспеч. по ORG_NUMBER */

def var ovd    as decimal no-undo.
def var ovd30  as decimal no-undo.
def var ovd60  as decimal no-undo.
def var ovd90  as decimal no-undo.
def var ovd120 as decimal no-undo.
def var ovd150 as decimal no-undo.
def var ovd180 as decimal no-undo.
def var ovlod  as decimal no-undo.
def var ovldod as decimal no-undo.

def var pr_sint as decimal no-undo.
def var sint as decimal no-undo.
def var sloan as decimal no-undo.
def var sovd as decimal no-undo.
def var sovl as decimal no-undo.


def temp-table t-debt no-undo
    field fio                as char  /* Ф.И.О клиента                      */
    field cif                as char  /* Ф.И.О клиента                      */
    field contract_number    as char  /* Номер карт-счета                   */
    field rnn                as char  /* Номер карт-счета                   */
    field dpk                as char  /* Категория ДПЛК                     */
    field dplk_cat           as int   /* Категория ДПЛК приведенная в соответсвие с ДПК                    */
    field dpk_cat            as int   /* Категория ДПК                      */
    field dplk_rec_cat       as int   /* Рекомендумеая категория ДПЛК       */
    field dpk_rec_cat        as int   /* Рекомендумеая категория ДПК        */ 
    index fio is primary fio.


def stream v-out.

find last crchis where crchis.regdt <= fdate and crchis.crc = 2 no-lock no-error.
if avail crchis then
    usdrate = crchis.rate[1].

for each dolg_client no-lock.	

    find last card_status where card_status.account_number = dolg_client.contract_number no-lock no-error. 
    if not avail card_status then do:
       next.
    end.

    find last month_clients where month_clients.contract_number = card_status.account_number no-lock use-index contract_number no-error.
    if not avail month_clients then do:
       next.
    end.

    /* обеспечение */
    if (dolg_client.credit_limit > 0) and 
       (left-trim(dolg_client.org_number, '0') begins 'D' or dolg_client.org_number = 'Spec') then do:
        sup2 = sup2 + dolg_client.credit_limit * {&CONCURRCONV}.
    end.

    ovd    = 0.
    ovd30  = 0.
    ovd60  = 0.
    ovd90  = 0.
    ovd120 = 0.
    ovd150 = 0.
    ovd180 = 0.
    ovlod  = 0.
    ovldod = 0.

    pr_sint = 0.
    sint    = 0.
    sloan   = 0.
    sovd    = 0.
    sovl    = 0.

    for each dolg_accnt of dolg_client.
        
        if account_name = 'Cl Security Deposit' and account_balance > 0 then
            sup1 = sup1 + account_balance * {&ACCCURRCONV}.
        
        if account_balance < 0 then do:
            case account_name:
                when 'Cl OVD'                then ovd    = ovd    + account_balance.
                when 'Cl OVD 30'             then ovd30  = ovd30  + account_balance.
                when 'Cl OVD 60'             then ovd60  = ovd60  + account_balance.
                when 'Cl OVD 90'             then ovd90  = ovd90  + account_balance.
                when 'Cl OVD 120'            then ovd120 = ovd120 + account_balance.
                when 'Cl OVD 150'            then ovd150 = ovd150 + account_balance.
                when 'Cl OVD 180'            then ovd180 = ovd180 + account_balance.
                when 'Cl OVL OverDue'        then ovlod  = ovlod  + account_balance.
                when 'Cl OVL Debit OverDue'  then ovldod = ovldod + account_balance.
            end.

            
            if account_name matches "*Loan*" then sloan = sloan + account_balance.
            else if account_name matches "*OVD*" and (not account_name matches "*Interest*") then sovd = sovd + account_balance.
            else if account_name matches "*OVL*" and (not (account_name matches "*Cl Interest OVL*")) then sovl = sovl + account_balance.

            if account_name matches "*Interest*" then do:

               if account_name matches "*OVD*" then pr_sint = pr_sint + account_balance.
                                               else sint = sint + account_balance.
            end.

        end.

    end.

    if pr_sint + sint + sloan + sovd + sovl = 0 then do:
        next.
    end.


    cat = 0.

    /* вычисляем категорию ПО КАРТОЧКАМ */

    if sup1 <> 0 and sup2 <> 0 then  
       sup = sup1.

    if sup1 = 0 and sup2 <> 0 then
       sup = sup2.

    if sup1 <> 0 and sup2 = 0 then
       sup = sup1.

    if sup > 2500 then
    sup = sup / usdrate.


    if sup <> 0 then do:
        /* обеспеченые */
        if ovd90  <> 0 then cat = 5.
        else if ovd <> 0 or ovd60 <> 0 or ovd30 <> 0 or ovlod <> 0 or ovldod <> 0 then cat = 3.
        else cat = 1.
    end. else do:
        /* необеспеченные */
        if ovd30 <> 0 or ovd60 <> 0 or ovd90 <> 0  then cat = 7.
        else if ovd <> 0 or ovlod <> 0 or ovldod <> 0 then cat = 6.
        else cat = 2.
    end.

    create t-debt.
      assign
         t-debt.fio                 = month_clients.full_name
         t-debt.rnn                 = card_status.rnn
         t-debt.contract_number     = dolg_client.contract_number.
         t-debt.dpk                 =  cats[cat].
    
    if  cat <= 5 then t-debt.dplk_cat = 2.
    if  cat = 6  then t-debt.dplk_cat = 6.
    if  cat = 7  then t-debt.dplk_cat = 7.

    /* Ищем в кредитах */

      find last cif where cif.jss = t-debt.rnn no-lock no-error.
      if avail  cif then do:

           t-debt.fio = cif.name.
           t-debt.cif = cif.cif.
           t-debt.dpk = string(cat).

           find last lonhar where lonhar.cif = cif.cif no-lock no-error. 

           if avail  lonhar then  do:
           
               find last lon where lon.lon = lonhar.lon no-lock no-error .

                     if avail lon then do:

                     if lon.grp = 90 or lon.grp = 92 then do:
                         
                         t-debt.dpk_cat = lonhar.lonstat.

                         if t-debt.dpk_cat > t-debt.dplk_cat then 
                             dplk_rec_cat = t-debt.dpk_cat. 
                         if t-debt.dpk_cat < t-debt.dplk_cat then 
                             dpk_rec_cat  = t-debt.dplk_cat.

                     end.

               end. 

           end.


      end. 


end.

def var v-i as int no-undo.

output stream v-out to crd_deb_rep.html.

put stream v-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

find last cmp no-lock no-error.

put stream v-out unformatted  "<h2>Общие задолжности  " cmp.name "</h2>" skip. 
put stream v-out unformatted  "<br>" string(today) skip. 

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip. 

put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>N</td>"
                         "<td>Клиент</td>"
                         "<td>ФИО</td>"
                         "<td>Карт счет </td>"
                         "<td>Категория ДПЛК</td>"
                         "<td>Категория ДПК</td>"
                         "<td>Рекомендумеая <br>категория ДПЛК</td>"
                         "<td>Рекомендумеая <br>категория ДПК </td>"
                         "</tr>"
                          skip.


for each  t-debt break by t-debt.fio.
     
     

     if t-debt.dpk_cat > 0 then do:
     
     v-i = v-i  + 1.


     put stream v-out unformatted 
                            "<tr>"                                       skip
                            "<td>"  string (v-i)                 "</td>" skip
                            "<td>"  t-debt.cif                   "</td>" skip
                            "<td>"  t-debt.fio                   "</td>" skip
                            "<td>"  t-debt.contract_number       "</td>" skip
                            "<td>"  string (t-debt.dplk_cat)     "</td>" skip
                            "<td>"  string (t-debt.dpk_cat)      "</td>" skip
                            "<td>"  if t-debt.dplk_rec_cat = 0 then "&nbsp;" else  string (t-debt.dplk_rec_cat) "</td>" skip
                            "<td>"  if t-debt.dpk_rec_cat = 0 then "&nbsp;" else string (t-debt.dpk_rec_cat)  "</td>" skip
                            "</tr>" skip.                                  

     end.

end.

output stream v-out close.
unix silent value("cptwin crd_deb_rep.html excel").

