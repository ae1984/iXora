/* vcrep5ctformrs.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
       Вывод нового способа расчета
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK
 * AUTHOR
       04.03.2011 aigul
 * CHANGES

 */
def input parameter a as char.
def input parameter b as char.
def output parameter p as char.
def var c as char.
def var d as char.
def var f as char.
def var c1 as char.
def var c2 as char.
def var i as int.
def var j as int.
def var d1 as char.
def var d2 as char.
i = 0.
c1 = "". c2 = "". c = "". d = "". f = "".
if num-entries(b) > num-entries(a) then do:
    if index(b,a) > 0 then f = substr(b,length(a) + 2).
    else do:
      i = i + 1.
      repeat i = 1 to num-entries(a):
        if num-entries(a) >= i then c1 = entry(i,a).
        if num-entries(b) >= i then c2 = entry(i,b).
            if c1 <> c2 then do:
              if c = "" then c = c1.
              else c = c + "," + c1.
            end.
      end.
      repeat i = 1 to num-entries(b):
        if num-entries(b) >= i then c2 = entry(i,b).
        if num-entries(a) >= i then c1 = entry(i,a).
           if c1 <> c2 then do:
              if d = "" then d = c2.
              else d = d + "," + c2.
           end.
        end.
    f = c + "/" + d.
    end.
end.
i = 0.
if num-entries(b) < num-entries(a) then do:
    i = i + 1.
    repeat i = 1 to num-entries(a):
        if num-entries(a) >= i then c1 = entry(i,a).
        if num-entries(b) >= i then c2 = entry(i,b).
        if c1 <> c2 then do:
           if c = "" then c = c1.
           else c = c + "," + c1.
        end.
    end.
    repeat i = 1 to num-entries(b):
        if num-entries(b) >= i then c2 = entry(i,b).
        if num-entries(a) >= i then c1 = entry(i,a).
        if c1 <> c2 then do:
           if d = "" then d = c2.
           else d = d + "," + c2.
        end.
    end.
    f = c + "/" + d.
end.
if num-entries(b) = num-entries(a) then do:
    i = i + 1.
    repeat i = 1 to num-entries(a):
        if num-entries(a) >= i then c1 = entry(i,a).
        if num-entries(b) >= i then c2 = entry(i,b).
        if c1 <> c2 then do:
           if c = "" then c = c1.
           else c = c + "," + c1.
        end.
    end.
    repeat i = 1 to num-entries(b):
        if num-entries(b) >= i then c2 = entry(i,b).
        if num-entries(a) >= i then c1 = entry(i,a).
        if c1 <> c2 then do:
           if d = "" then d = c2.
           else d = d + "," + c2.
        end.
    end.
    f = c + "/" + d.
end.

p = f.