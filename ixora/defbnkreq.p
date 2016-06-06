/* defbnkreq.p
 * MODULE
        Сборка полного адреса банка (адрес, тел и т.п.) для печати во всяких документах
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9.1.1.1
 * AUTHOR
        16.06.2003 nadejda
 * CHANGES
        11.02.2004 suchkov - Поправлены позиции в связи с добавлением e-mail для отправки балансов по городам.
*/


{global.i}

{sysc.i}

def output parameter v-bankfull as char.

def var v-str1 as char.
def var s as char.
def var i as integer.

v-bankfull = "".

find first cmp no-lock no-error.

v-str1 = get-sysc-cha("bnkadr").
if v-str1 <> "" and v-str1 <> ? then do:
  i = num-entries(v-str1, "|").

  if i >= 7 then v-bankfull = entry(7, v-str1, "|").
  
  if i >= 8 then do:
    s = entry(8, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + s.
    end.
  end.
   
  if i >= 9 then do:
    s = entry(9, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + s.
    end.
  end.

  if i >= 1 then do:
    s = entry(1, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + s.
    end.
  end.
      
  if cmp.tel <> "" then do:
    if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
    v-bankfull = v-bankfull + "phone:&nbsp;" + replace(string(cmp.tel, "(xxxx) xxxxxx"), " ", "&nbsp;").
  end.

  if i >= 2 then do:
    s = entry(2, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + "fax:&nbsp;" + replace(string(s, "(xxxx) xxxxxx"), " ", "&nbsp;").
    end.
  end.

  if i >= 3 then do:
    s = entry(3, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + "telex:&nbsp;" + replace(s, " ", "&nbsp;").
    end.
  end.

  if i >= 4 then do:
    s = entry(4, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + "S.W.I.F.T.&nbsp;" + replace(s, " ", "&nbsp;").
    end.
  end.
  
  if i >= 5 then do:
    s = entry(5, v-str1, "|").
    if s <> "" then do:
      if v-bankfull <> "" then v-bankfull = v-bankfull + ", ".
      v-bankfull = v-bankfull + "<NOBR>e-mail:</NOBR>&nbsp;" + s.
    end.
  end.
end.
