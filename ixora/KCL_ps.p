/* KCL_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование сообщений в kcell
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        26/11/03 kanat - переделал формирование счетчика в KCMAIL - теперь этот счетчик обнуляется раз в месяц
        16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес abpk@elexnet.kz
        15/04/06 tsoy      - добавил в формат цифр
        19/04/06 tsoy      - посылать по FTP 
        20/04/06 tsoy      - Изменил тему письма 
        08/06/06 tsoy      - Добавил Админов БД в рассылку и изменил формат формирования файла согластно требуемым форматам
        29/06/06 tsoy      - Теперь номер телефона 10 знаков с учетом новго префикса 701

*/

{lgps.i "new"}
{comm-txb.i}
{u-2-d.i}
{d-2-u.i}
{global.i}
{padl.i}

def var v-cell-number  as char.

def var v-mail as char init "it@elexnet.kz".
find sysc where sysc.sysc = "KCL_ps" no-lock no-error.
if avail sysc then v-mail = sysc.chval.

def var dlm as char init " " format "x(1)".
def var crlf as char format "x(1)".
def var cnt as int init 0.
def var fname as char.
def var cnt0 as int init 0.
def var cTitle as char.
def var dates as char.
def var v-s as char.
def var v-v as char.
def var bik like bankl.bank.
def var accbn like aaa.aaa.
def var probel as char.
def var date_1 as char.
def var date_gmd as char.
def var date_mdg as char.
def var file_name as char.
def var count as int init 0.
def var Net_prefix as char init 'TKE'.
def var Common_prefix as char init 'TK'.
def var first_line as char.
def var second_line as char. 
def var v-file as char.
def var s_docid as char.
def var pay_amount as char.
def var i_rid_temp as integer.
def var s_valdate_temp as char.
def var s_ref_temp as char.
def var s_rid_found as char.
def var s_email_title as char.

def var i_payment_type_1 as integer.
def var i_payment_type_2 as integer.
def var i_mail_count as integer init 0.

def var ourbank as char.
ourbank = comm-txb().

crlf = chr(10).

find sysc where sysc.sysc = "KCMAIL" no-error.
if avail sysc then do:

    if month(sysc.daval) <> month(g-today) then
    sysc.inval = 1.
    sysc.daval = g-today.
end.

for each mobtemp where state = 3: mobtemp.state = 4. end.
select count (*) into cnt0 from mobtemp where state = 4.

if can-find (first mobtemp where mobtemp.state = 4 no-lock) then do:

   find first mobtemp where mobtemp.state = 4 no-lock no-error.
   if avail mobtemp then do:
   i_rid_temp = mobtemp.rid.
   s_valdate_temp = string(mobtemp.valdate,'99.99.9999').
   s_ref_temp = trim(mobtemp.ref).
   s_rid_found = 'yes'.
   i_payment_type_1 = mobtemp.rid.
   end.

   run savelog ("ibcom_ps", "").
   run savelog ("ibcom_ps", "Начало выгрузки платежей KCell").

   output to ibcomtmp.txt.
   for each mobtemp where state = 4:

   i_payment_type_2 = mobtemp.rid.

      count = count + 1.

                if i_payment_type_1 = i_payment_type_2 then do:

    run savelog ("ibcom_ps", " -Phone (KCell) - " + mobtemp.phone + 
                             " Date - " + string (valdate) +
                             " Time - " + string(mobtemp.ctime, "hh:mm:ss") +
                             " Sum - " + string(mobtemp.sum, "zzzzzzzzz9.99") +
                             " Acc - " + string(mobtemp.ls) +
                             " jou/rmz - " + string(mobtemp.ref) +
                             " Npl - " + mobtemp.npl).
       cnt = cnt + 1.

   mobtemp.ctime = count.

   probel = chr(250).

   find sysc where sysc.sysc = 'clecod' no-lock no-error.
   if not avail sysc or sysc.chval = '' then do:
      v-text =
      'File upload error!' +
      'Call administrator!!!'.
          run lgps.
          run mail(v-mail, 
                "TEXAKABANK SENDER <abpk@elexnet.kz>", 
                'File upload error!!!', 
                STRING(TIME,"HH:MM AM") + ' Beneficiary attributes were not found!', '1', '', '').
      leave.
   end.
    
   bik = sysc.chval.
   accbn = '019467476'.

   date_1 = string( mobtemp.valdate, '99/99/9999' ).
   date_gmd = substr( date_1, 7, 4 ) + '/' + substr( date_1, 4, 3 ) + substr( date_1, 1, 2 ).        /* 2002/12/25 */
   date_mdg = substr( date_1, 1, 2 ) + '/' + substr( date_1, 4, 2 ) + '/' + substr( date_1, 7, 4 ).  /* 12/25/2002 */

   def var month_1 as char. 

   month_1 = string(month(today)).

   if month_1 = "10" then month_1 = "A". 
   if month_1 = "11" then month_1 = "B". 
   if month_1 = "12" then month_1 = "C". 

   /*
   rid = 1 - Internet - office payments
   rid = 0 - Common payments
   */

        find sysc where sysc.sysc = "KCMAIL" no-error.
        if avail sysc then do:
         i_mail_count = sysc.inval.
         i_mail_count = i_mail_count + 1.
         sysc.inval = i_mail_count.
        end.

   if mobtemp.rid = 1 then
       file_name = Net_prefix + substr( date_1, 4, 2 ) + substr( date_1, 1, 2 ) + trim( string( i_mail_count, '9999999' )) + ".prn".
   else
       file_name = Common_prefix + trim ( string ( i_mail_count, '99999' )) + "."  + month_1 + string(day(today), "99").

   s_docid = mobtemp.ref.

   first_line = bik + probel + accbn + probel + date_gmd + chr( 13 ) + chr( 10 ). 

   put unformatted first_line.


   pay_amount = trim(string(mobtemp.sum,">>>>>>>>9.99")). 
   v-cell-number = trim(mobtemp.phone).

   if today >= 07/01/2006 then v-cell-number = "701" + v-cell-number.


   second_line = date_mdg                + probel +   
   s_docid                               + probel + 
   pay_amount                            + probel +
   u-2-d( trim( mobtemp.info ))          + " БҐ«." + trim(v-cell-number) + probel + '' + probel +
   bik                                   + probel + 
   "000000000"                           + probel + 
   ''                                    + probel +
   v-cell-number                         + probel + probel +
   bik                                   +  
   mobtemp.jou                           + ' ' +
   u-2-d(mobtemp.npl).

   put unformatted second_line.

   if cnt < cnt0 then put unformatted crlf.

   mobtemp.state = 5.

   delete mobtemp.
   
                end.
   end.
   output close.

   v-text = "Отправка реестра текущих платежей K-Cell всего - " +
            trim(string(cnt),"zzz9") + ") ".
   run lgps .

   unix silent value ("cat ibcomtmp.txt > " + file_name).

   def var tempstr as char.
     
   input through value( ' hostname '). 
   repeat:
       import tempstr.
   end.
   input close.  

   def var v-ftp as logi init false .

   if tempstr = "texaka1" then do:

      /* запускаем только на боевом, т.к. put_kcell сработает и на тестовом */
      run put_kcell (input file_name, output v-ftp) .

      /* eсли неудачно то попробовать еще раз  */
      if not v-ftp then 
         run put_kcell (input file_name, output v-ftp) .

      if v-ftp then 
           run mail( v-mail , 'TEXAKABANK SENDER',  'encrypt_for_kcell', s_email_title, '1', '', file_name ).
       else 
           run mail( v-mail, 'TEXAKABANK SENDER',  'ERROR!!! encrypt_for_kcell ', s_email_title, '1', '', file_name ).

   end.

   /*
   if not v-ftp then do:

        if i_rid_temp = 1 then do:

           s_email_title = d-2-u('ЃҐ§­ «ЁГ­К© Ї« БҐ¦ Kcell §  ' + s_valdate_temp + ' ё. ' + file_name).

           run mail("For KCELL <municipal" + ourbank + "@elexnet.kz>, EXPORTER <export@mail.texakabank.kz>", 
                    "TEXAKABANK SENDER <abpk@elexnet.kz>", "encrypt_for_kcell", s_email_title, "1", "", file_name ).

        end.
        else do:
           s_email_title = d-2-u('Џ« БҐ¦ KCell §  ' + s_valdate_temp + 'ё. N ' + s_ref_temp).

           run mail("For KCELL <municipal" + ourbank + "@elexnet.kz>, EXPORTER <export@mail.texakabank.kz>", 
                    "TEXAKABANK SENDER <abpk@elexnet.kz>", "encrypt_for_kcell", s_email_title, "1", "", file_name ).

        end.

   end.
   */

   s_rid_found  = 'no'. 
 
   unix silent value ("rm -f " + file_name).

   unix silent value ("rm ibcomtmp.txt").

end.
release mobtemp.

