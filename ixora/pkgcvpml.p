

{global.i}
{pk.i}
{pk-sysc.i}
{sysc.i}

def stream out1.
define shared var v-fmsg as char no-undo.

/**
s-credtype = "3".
s-pkankln = 8.
**/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.



  def var p-sik as char.
  def var p-lastname as char.
  def var p-firstname as char.
  def var p-midname as char.
  def var p-plastname as char.
  def var p-birthdt as char.
  def var p-numpas as char.
  def var p-dtpas as char.
  def var v-file as char.
  def var v-date as char.
  def var v-sr as char.
  def var v-dirq as char.
  def var num as inte.
  def var v-codrel as char.

  v-codrel = "".
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik" no-lock no-error.
  if not avail pkanketh or pkanketh.rescha[3] ne "" then do:
      if not v-inet then
      message skip " Запрос данных в ГЦВП по СИК '" + pkanketh.value1 + "' уже был отправлен !" skip "Дождитесь ответа !" skip(1)
              view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
      
      return.
  end.

  find first sysc where sysc.sysc = "PKGCVY" no-lock no-error.
  if not avail sysc or not sysc.loval then do:
      if not v-inet then
          message skip " ГЦВП - Запрос данных в ГЦВП в данный момент не работает !" skip(1)
              view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
      else 
         run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"ГЦВП - Запрос данных в ГЦВП в данный момент не работает!").
  end.
  else do:
    num = next-value(pk-gcvp).
    v-sr = string(get-pksysc-int ("gcvpsr")).
    v-date = substr(string(g-today), 1, 6) + string(year(g-today)).
    v-dirq = get-sysc-cha ("pkgcvq").
    v-file = fill("0", 8 - length(trim(string(num)))) + trim(string(num)).
    v-codrel = "".
    
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik" no-lock no-error.
    p-sik = caps(trim(pkanketh.value1)).

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "pname" no-lock no-error.
    if avail pkanketh and trim(pkanketh.value1) <> "" then do:
      p-lastname = caps(trim(pkanketh.value1)).
      
      /* выяснилось, что в документе СИКа могут быть указаны и прежние, и новые данные - тогда они через слэш
         и ГЦВП проверяет по ПЕРВОМУ значению, то есть по текущей фамилии!
         для отслеживания этого факта служит критерий ciktwo :  если = 1, то посылать текущие данные, нет - старые
      */
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "siktwo" no-lock no-error.
      if avail pkanketh and trim(pkanketh.value1) <> "" and integer(trim(pkanketh.value1)) = 1 then do:
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "lname" no-lock no-error.
        p-lastname = caps(trim(pkanketh.value1)).
      end.
    end.
    else do:
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "lname" no-lock no-error.
      p-lastname = caps(trim(pkanketh.value1)).
    end.
    
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "fname" no-lock no-error.
    if avail pkanketh then p-firstname = caps(trim(pkanketh.value1)).
    
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "mname" no-lock no-error.
    if avail pkanketh then p-midname = caps(trim(pkanketh.value1)).
    
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "bdt" no-lock no-error.
    if avail pkanketh then p-birthdt = string(date(pkanketh.value1), "99/99/9999").

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
    if avail pkanketh then p-numpas = caps(trim(pkanketh.value1)).

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "dtpas" no-lock no-error.
    if avail pkanketh then p-dtpas = string(date(pkanketh.value1), "99/99/9999").
    
    output stream out1 to rpt.img.
    put stream out1 unformatted  v-file + "|" +  v-date + "|" + p-sik + "|" + p-lastname + "|" +
                                 p-firstname + "|" + p-midname + "|" + p-birthdt +  "|" + p-numpas "|" + p-dtpas "|" + v-file + "|" +
                                 v-date + "|" + v-sr + "|" skip.
    output stream out1 close.
    
    unix silent un-win rpt.img value(v-file).
    unix silent cp value(v-file) value(v-dirq + v-file).
    
    find sysc where sysc.sysc = "pkgcvm" no-lock no-error.
    
/*    run mail(trim(sysc.chval), "MKO NK <abpk@metrobank.kz>", "Fdjkl358Jd", "" , "1", "", v-file).*/
    run savelog( "gcvpout", "Отправка файла в ГЦВП : " + v-file).
    
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik"  no-error.
    pkanketh.rescha[3] = "nk" + v-file.
    
    unix silent cp value(v-file) value(v-dirq + v-file).
    unix silent rm -f value(v-file).
    
    create gcvp.
    assign gcvp.bank = s-ourbank
           gcvp.lname = p-lastname
           gcvp.fname = p-firstname
           gcvp.mname = p-midname
           gcvp.dtb = date(p-birthdt)
           gcvp.sik = p-sik
           gcvp.ofc = g-ofc
           gcvp.rdt = g-today
           gcvp.nfile = v-file.
    release gcvp.

    if not v-inet then
          message skip " Запрос данных в ГЦВП в отправлен !" skip(1)  view-as alert-box buttons ok title " ВНИМАНИЕ ! ".

  end.
