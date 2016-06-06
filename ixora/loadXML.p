/* loadXML.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30.04.2013 evseev - tz-1810
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def input parameter fname as char no-undo.
def input parameter  xml_id  as int  no-undo.

def new shared var filename as char no-undo.
filename = fname.
def new shared temp-table xmlpars no-undo
  field par as char
  field val as char.

def var v-line       as int  no-undo.


def var v-exist1    as char no-undo.
def var v-xmlpath as char.
v-xmlpath = "/data/import/1cb/" + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".
input through value( "find " + v-xmlpath + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-xmlpath).
    unix silent value("chmod 777 " + v-xmlpath).
end.
unix silent value('cp ' + trim(filename) + ' ' + v-xmlpath).



if xml_id <= 0 then do:
    function GetXmlId returns integer.
        do transaction:
            find first pksysc where pksysc.sysc = "xml_id" exclusive-lock no-error.
            if avail pksysc then
               pksysc.chval = string(int(pksysc.chval) + 1).
            else do:
               create pksysc.
               pksysc.sysc = "xml_id".
               pksysc.chval = "1".
            end.
            find first pksysc where pksysc.sysc = "xml_id" no-lock no-error.
        end.
        return int(pksysc.chval).
    end function.

    xml_id = GetXmlId().
end.

/*filename = "XmlData1.xml".*/
run XMLParser.


do transaction:
   create xml.
   assign
      xml.xml_id = xml_id
      xml.dt = today
      xml.tm  = time
      xml.usr = g-ofc
      xml.file = filename.
   v-line = 0.
   for each xmlpars:
       v-line = v-line + 1.
       create xml_det.
       assign
          xml_det.xml_id = xml_id
          xml_det.line = v-line
          xml_det.par = xmlpars.par
          xml_det.val = xmlpars.val.

   end.
end.


