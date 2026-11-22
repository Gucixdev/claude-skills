"""A board made from code with KiCad's pcbnew: 30 x 20 mm, two 2-pin headers joined by a 0.3 mm track.

Why code: the board is a function of its parameters, a diff shows what changed, and pcb-check can prove the result.
usage: python3 pcb_demo.py OUT.kicad_pcb [bad]   ("bad" adds a track of net B 0.4 mm from track A: a clearance violation on purpose)
"""
import sys
import pcbnew

out = sys.argv[1]
bad = len(sys.argv) > 2 and sys.argv[2] == "bad"
mm = pcbnew.FromMM
b = pcbnew.CreateEmptyBoard()


def net(name):
    n = pcbnew.NETINFO_ITEM(b, name)
    b.Add(n)
    return n


def header(ref, x, y, nets):
    fp = pcbnew.FOOTPRINT(b)
    fp.SetReference(ref)
    fp.SetPosition(pcbnew.VECTOR2I(mm(x), mm(y)))
    for i, n in enumerate(nets):
        p = pcbnew.PAD(fp)
        p.SetNumber(str(i + 1))
        p.SetShape(pcbnew.PAD_SHAPE_CIRCLE)
        p.SetAttribute(pcbnew.PAD_ATTRIB_PTH)
        p.SetSize(pcbnew.VECTOR2I(mm(1.7), mm(1.7)))
        p.SetDrillSize(pcbnew.VECTOR2I(mm(1.0), mm(1.0)))
        p.SetLayerSet(p.PTHMask())
        p.SetPosition(pcbnew.VECTOR2I(mm(x), mm(y + 2.54 * i)))
        p.SetNet(n)
        fp.Add(p)
    b.Add(fp)


a, c = net("A"), net("B")
header("J1", 5, 5, [a, c])
header("J2", 25, 5, [a, c])


def track(n, y):
    t = pcbnew.PCB_TRACK(b)
    t.SetStart(pcbnew.VECTOR2I(mm(5), mm(y)))
    t.SetEnd(pcbnew.VECTOR2I(mm(25), mm(y)))
    t.SetWidth(mm(0.3))
    t.SetLayer(pcbnew.F_Cu)
    t.SetNet(n)
    b.Add(t)


track(a, 5)
track(c, 5 + 2.54)
if bad:
    t = pcbnew.PCB_TRACK(b)
    t.SetStart(pcbnew.VECTOR2I(mm(10), mm(5.4)))
    t.SetEnd(pcbnew.VECTOR2I(mm(20), mm(5.4)))
    t.SetWidth(mm(0.3))
    t.SetLayer(pcbnew.F_Cu)
    t.SetNet(c)
    b.Add(t)

for (x1, y1, x2, y2) in [(0, 0, 30, 0), (30, 0, 30, 20), (30, 20, 0, 20), (0, 20, 0, 0)]:
    s = pcbnew.PCB_SHAPE(b)
    s.SetShape(pcbnew.SHAPE_T_SEGMENT)
    s.SetStart(pcbnew.VECTOR2I(mm(x1), mm(y1)))
    s.SetEnd(pcbnew.VECTOR2I(mm(x2), mm(y2)))
    s.SetLayer(pcbnew.Edge_Cuts)
    s.SetWidth(mm(0.1))
    b.Add(s)

pcbnew.SaveBoard(out, b)
print("wrote", out)
