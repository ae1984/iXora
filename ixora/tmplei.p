/* tmplei.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Экспорт-импорт шаблона
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
        10/06/2005 madiar
 * CHANGES
*/

def var v-templ as char.
def var v-file as char.
def var v-txt as char.
def var coun as integer.

def stream rep.

def var v-sel as char init '0'.    
run sel2 ("Выбор :", " 1. Экспорт шаблона | 2. Импорт шаблона ", output v-sel).
if v-sel = '0' then return.

if v-sel = '1' then do:
  
  form skip(1)
       v-templ label " Шаблон для экспорта " validate(can-find(trxhead where trxhead.System = substring(v-templ,1,3) and trxhead.code = integer(substring(v-templ,4,4))), " неверное имя шаблона ") format "x(7)" skip
       v-file label " Имя файла           " format "x(20)" validate(trim(v-file) <> ''," некорректное имя файла ") skip
       skip(1)
       with side-label centered row 7 frame fr.
  
  update v-templ with frame fr.
  if trim(v-templ) <> '' then do:
    v-file = v-templ + ".tmpl".
    displ v-file with frame fr.
  end.
  update v-file with frame fr.
  
  hide frame fr.
  
  output stream rep to value(v-file).
  
  put stream rep unformatted
    "trxname^" v-templ skip.
  
  find trxhead where trxhead.System = substring(v-templ,1,3) and trxhead.code = integer(substring(v-templ,4,4)) no-error.
  put stream rep unformatted
    "trxhead^"
    trxhead.System "^"
    trxhead.des "^" 
    trxhead.code "^" 
    trxhead.sts "^"
    trxhead.sts-f "^" 
    trxhead.party "^"
    trxhead.party-f "^"
    trxhead.point "^"
    trxhead.point-f "^"
    trxhead.depart "^"
    trxhead.depart-f "^"
    trxhead.opt-f "^"
    trxhead.mult-f "^"
    trxhead.mult "^"
    trxhead.opt "^"
    trxhead.who "^" 
    trxhead.whn "^" 
    trxhead.tim skip.

  for each trxtmpl where trxtmpl.code = v-templ no-lock:
  put stream rep unformatted
    "trxtmpl^"
    trxtmpl.code "^"
    trxtmpl.amt "^"
    trxtmpl.dracc "^"
    trxtmpl.cracc "^"
    trxtmpl.rem[1] "^" trxtmpl.rem[2] "^" trxtmpl.rem[3] "^" trxtmpl.rem[4] "^" trxtmpl.rem[5] "^"
    trxtmpl.who "^"
    trxtmpl.whn "^"
    trxtmpl.ln "^"
    trxtmpl.System "^"
    trxtmpl.lgr "^"
    trxtmpl.name "^"
    trxtmpl.amt-f "^"
    trxtmpl.amt-refln "^"
    trxtmpl.cracc-f "^"
    trxtmpl.dracc-f "^"
    trxtmpl.crgl "^"
    trxtmpl.drgl-f "^"
    trxtmpl.drgl "^"
    trxtmpl.crgl-f "^"
    trxtmpl.crc-f "^"
    trxtmpl.rate "^"
    trxtmpl.rate-f "^"
    trxtmpl.drsub "^"
    trxtmpl.crsub "^"
    trxtmpl.drsub-f "^"
    trxtmpl.crsub-f "^"
    trxtmpl.crc "^"
    trxtmpl.rem-f[1] "^" trxtmpl.rem-f[2] "^" trxtmpl.rem-f[3] "^" trxtmpl.rem-f[4] "^" trxtmpl.rem-f[5] "^"
    trxtmpl.dev "^"
    trxtmpl.cev "^"
    trxtmpl.dev-f "^"
    trxtmpl.cev-f skip.
  end.
  
  for each trxlabs where trxlabs.code = v-templ no-lock:
    put stream rep unformatted
      "trxlabs^"
      trxlabs.code "^"
      trxlabs.ln "^"
      trxlabs.fld "^"
      trxlabs.des "^"
      trxlabs.lf skip.
  end.
  
  for each trxcdf where trxcdf.trxcode = v-templ:
    put stream rep unformatted
      "trxcdf^"
      trxcdf.trxcode "^"
      trxcdf.trxln "^"
      trxcdf.codfr "^"
      trxcdf.drcod "^"
      trxcdf.drcod-f "^"
      trxcdf.crcod "^"
      trxcdf.crcode-f "^"
      trxcdf.who "^"    
      trxcdf.whn skip.
  end.
  
  output stream rep close.
  hide message no-pause.
  return.
  
end. /* if v-sel = '1' */


if v-sel = '2' then do:
  
  form skip(1)
       v-file label " Имя файла " validate(trim(v-file) <> ''," некорректное имя файла ") format "x(20)" skip
       skip(1)
       with side-label centered row 7 frame fr1.
  
  update v-file with frame fr1.
  
  hide frame fr1.
  
  input stream rep from value(v-file).
  
  coun = 0.
  repeat:
    import stream rep unformatted v-txt.
    if v-txt <> "" then do:
      case entry(1,v-txt,"^"):
        when "trxname" then do:
          v-templ = entry(2,v-txt,"^").
        end.
        when "trxhead" then do:
          create trxhead.
          trxhead.System = entry(2,v-txt,"^").
          trxhead.des = entry(3,v-txt,"^").
          trxhead.code = integer(entry(4,v-txt,"^")).
          trxhead.sts = integer(entry(5,v-txt,"^")).
          trxhead.sts-f = entry(6,v-txt,"^").
          trxhead.party = entry(7,v-txt,"^").
          trxhead.party-f = entry(8,v-txt,"^").
          trxhead.point = integer(entry(9,v-txt,"^")).
          trxhead.point-f = entry(10,v-txt,"^").
          trxhead.depart = integer(entry(11,v-txt,"^")).
          trxhead.depart-f = entry(12,v-txt,"^").
          trxhead.opt-f = entry(13,v-txt,"^").
          trxhead.mult-f = entry(14,v-txt,"^").
          trxhead.mult = integer(entry(15,v-txt,"^")).
          trxhead.opt = entry(16,v-txt,"^").
          trxhead.who = entry(17,v-txt,"^").
          trxhead.whn = date(entry(18,v-txt,"^")).
          trxhead.tim = integer(entry(19,v-txt,"^")).
          release trxhead.
        end.
        when "trxtmpl" then do:
          create trxtmpl.
          trxtmpl.code = entry(2,v-txt,"^").
          trxtmpl.amt = decimal(entry(3,v-txt,"^")).
          trxtmpl.dracc = entry(4,v-txt,"^").
          trxtmpl.cracc = entry(5,v-txt,"^").
          trxtmpl.rem[1] = entry(6,v-txt,"^").
          trxtmpl.rem[2] = entry(7,v-txt,"^").
          trxtmpl.rem[3] = entry(8,v-txt,"^").
          trxtmpl.rem[4] = entry(9,v-txt,"^").
          trxtmpl.rem[5] = entry(10,v-txt,"^").
          trxtmpl.who = entry(11,v-txt,"^").
          trxtmpl.whn = date(entry(12,v-txt,"^")).
          trxtmpl.ln = integer(entry(13,v-txt,"^")).
          trxtmpl.System = entry(14,v-txt,"^").
          trxtmpl.lgr = entry(15,v-txt,"^").
          trxtmpl.name = entry(16,v-txt,"^").
          trxtmpl.amt-f = entry(17,v-txt,"^").
          trxtmpl.amt-refln = integer(entry(18,v-txt,"^")).
          trxtmpl.cracc-f = entry(19,v-txt,"^").
          trxtmpl.dracc-f = entry(20,v-txt,"^").
          trxtmpl.crgl = integer(entry(21,v-txt,"^")).
          trxtmpl.drgl-f = entry(22,v-txt,"^").
          trxtmpl.drgl = integer(entry(23,v-txt,"^")).
          trxtmpl.crgl-f = entry(24,v-txt,"^").
          trxtmpl.crc-f = entry(25,v-txt,"^").
          trxtmpl.rate = decimal(entry(26,v-txt,"^")).
          trxtmpl.rate-f = entry(27,v-txt,"^").
          trxtmpl.drsub = entry(28,v-txt,"^").
          trxtmpl.crsub = entry(29,v-txt,"^").
          trxtmpl.drsub-f = entry(30,v-txt,"^").
          trxtmpl.crsub-f = entry(31,v-txt,"^").
          trxtmpl.crc = integer(entry(32,v-txt,"^")).
          trxtmpl.rem-f[1] = entry(33,v-txt,"^").
          trxtmpl.rem-f[2] = entry(34,v-txt,"^").
          trxtmpl.rem-f[3] = entry(35,v-txt,"^").
          trxtmpl.rem-f[4] = entry(36,v-txt,"^").
          trxtmpl.rem-f[5] = entry(37,v-txt,"^").
          trxtmpl.dev = integer(entry(38,v-txt,"^")).
          trxtmpl.cev = integer(entry(39,v-txt,"^")).
          trxtmpl.dev-f = entry(40,v-txt,"^").
          trxtmpl.cev-f = entry(41,v-txt,"^").
          release trxtmpl.
        end.
        when "trxlabs" then do:
          create trxlabs.
          trxlabs.code = entry(2,v-txt,"^").
          trxlabs.ln = integer(entry(3,v-txt,"^")).
          trxlabs.fld = entry(4,v-txt,"^").
          trxlabs.des = entry(5,v-txt,"^").
          trxlabs.lf = integer(entry(6,v-txt,"^")).
          release trxlabs.
        end.
        when "trxcdf" then do:
          create trxcdf.
          trxcdf.trxcode = entry(2,v-txt,"^").
          trxcdf.trxln = integer(entry(3,v-txt,"^")).
          trxcdf.codfr = entry(4,v-txt,"^").
          trxcdf.drcod = entry(5,v-txt,"^").
          trxcdf.drcod-f = entry(6,v-txt,"^").
          trxcdf.crcod = entry(7,v-txt,"^").
          trxcdf.crcode-f = entry(8,v-txt,"^").
          trxcdf.who = entry(9,v-txt,"^").
          trxcdf.whn = date(entry(10,v-txt,"^")).
          release trxcdf.
        end.
      end case.
      if coun = 0 then do:
        if v-templ <> '' then do:
          
          find trxhead where trxhead.System = substring(v-templ,1,3) and trxhead.code = integer(substring(v-templ,4,4)) no-error.
          if avail trxhead then do:
            find first trxtmpl where trxtmpl.code = v-templ no-lock no-error.
            if avail trxtmpl then do:
               message " Шаблон существует. Заменить? " view-as alert-box question buttons ok-cancel title "" update choice as logical.
               if not choice then do: message " импорт отменен ". return. end.
               else delete trxhead.
            end.
          end.
          for each trxtmpl where trxtmpl.code = v-templ:
            delete trxtmpl.
          end.
          for each trxlabs where trxlabs.code = v-templ:
            delete trxlabs.
          end.
          for each trxcdf where trxcdf.trxcode = v-templ:
            delete trxcdf.
          end.
          
        end.
        else do:
          message " Invalid format " view-as alert-box buttons ok.
          return.
        end.
      end.
      coun = coun + 1.
    end. /* if v-txt <> '' */
  end.
  
  input stream rep close.
  
  hide message no-pause.
  return.
  
end. /* if v-sel = '2' */

