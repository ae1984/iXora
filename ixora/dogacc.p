/* dogacc.p
 * MODULE
        Работа с клиентами
 * DESCRIPTION
        Печать договора открытия счета для юр лица 
 * RUN
        
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-2 Договор 
 * AUTHOR
        17.02.2004 marinav
 * CHANGES
        19.02.2004 marinav - Копирование логотип через cptwin 
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/


{global.i}
{sysc.i}

def shared var s-cif like cif.cif.    /*!!!!!*/

define var l-fl as logical.
define var v-fiobank as char.
define var v-cod as char.
define var v-logo as char.
define var v-dglogo as char.

v-logo = "top_logo_bw.gif".
v-dglogo = get-sysc-cha ("dglogo").
if v-dglogo = ? then v-dglogo = '/data/export'.
if not v-dglogo begins "/" then v-dglogo = "/" + v-dglogo.
if substr(v-dglogo, length(v-dglogo), 1) <> "/" then v-dglogo = v-dglogo + "/".

define var v-dt as date format '99/99/9999'.

find cif where cif.cif = s-cif and upper(cif.type) = 'B' no-lock no-error.
  if not avail cif then return.


v-dt =  g-today.
update v-dt label 'Введите дату открытия счета' with frame dat centered.

l-fl = no.
for each lgr where lgr.led eq "DDA" no-lock:
  find first aaa where aaa.cif = s-cif and aaa.lgr = lgr.lgr and aaa.regdt = v-dt 
             and aaa.sta ne "C" no-lock no-error .
  if avail aaa then l-fl = yes. 
end.

if not l-fl then do:
      message skip " В этот день счета не открывались !" skip(1)
        view-as alert-box buttons ok title " ОШИБКА ! ".
      return.
end.

run h-codfr ('dogsing', output v-cod).
find first codfr where codfr.codfr = 'dogsing' and codfr.code = v-cod no-lock no-error.
  if avail codfr then v-fiobank = codfr.name[1].

/*{logorcp.i}*/

def stream v-out.

def var v-ofile as char.
def var v-ifile as char.
def var v-infile as char.
def var v-str as char.
def var v-params as char init 
"city,dat,client,iik1,dat1,iik2,dat2,iik3,dat3,iik4,dat4,iik5,dat5,
fiobank,rnn,iik,fioclient,rnnbank,index,adress,logo".
def var i as integer.
def var v-param as logical.

def temp-table t-params 
  field kritcod as char
  field paramfind as char
  field data as char
  index main is primary unique paramfind.

do i = 1 to num-entries(v-params):
  create t-params.
  t-params.paramfind = entry(i, v-params).
  if t-params.paramfind begins 'iik' or t-params.paramfind begins 'dat' then
                      t-params.data = '________________'.
end.

i = 1.
for each lgr where lgr.led eq "DDA" no-lock:
  for each aaa where aaa.cif = s-cif and aaa.lgr = lgr.lgr and aaa.regdt = v-dt 
             and aaa.sta ne "C" no-lock.
    find t-params where t-params.paramfind = 'iik' + string(i) no-lock no-error.
    if avail t-params then assign  t-params.data = aaa.aaa.
    find t-params where t-params.paramfind = 'dat' + string(i) no-lock no-error.
    if avail t-params then assign  t-params.data = string(aaa.regdt, '99.99.9999') i = i + 1.
  end. 
end.

for each t-params:

  case t-params.paramfind:
    when "city" then do:
          find first cmp no-lock no-error.
          t-params.data = entry(1, cmp.addr[1]).
      end.
    when "adress" then do:
          find first cmp no-lock no-error.
          t-params.data = cmp.addr[1].
      end.
    when "rnnbank" then do:
          find first cmp no-lock no-error.
          t-params.data = entry(1, cmp.addr[2]).
      end.
    when "dat" then t-params.data = string(g-today, '99.99.9999').
    when "client" then t-params.data = cif.name.
    when "fiobank" then t-params.data = v-fiobank.
    when "rnn" then t-params.data = cif.jss.
    when "fioclient" then t-params.data = "_______________________________________________________________".
    when "index" then do:
       find sysc where sysc.sysc = "bnkadr" no-lock no-error.
       if avail sysc then 
         t-params.data = entry(1, sysc.chval, "|") no-error.
      end.
    when "logo" then t-params.data = v-logo .
  end case.

end.

/* печать  */

v-infile = "dgurid.htm" .
v-ofile = "dog.htm".
output stream v-out to value(v-ofile).

v-ifile = get-sysc-cha ("dgpath").
if v-ifile = ? then v-ifile = '/data/export/dogs/'.

if not v-ifile begins "/" then v-ifile = "/" + v-ifile.
if substr (v-ifile, length(v-ifile), 1) <> "/" then v-ifile = v-ifile + "/".
v-ifile = v-ifile + v-infile .

input from value(v-ifile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  /* заменить параметры на данные клиента */
  c-param:
  repeat:
    v-param = false.
    for each t-params:
      if v-str matches "*\{\&" + t-params.paramfind + "\}*" then do:
        v-param = true.

        v-str = replace (v-str, "\{\&" + t-params.paramfind + "\}", t-params.data).

      end.
    end.
    if not v-param then leave c-param.
  end.
  put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.

unix silent value("cptwin " + v-ofile + " iexplore " + v-dglogo + v-logo).



