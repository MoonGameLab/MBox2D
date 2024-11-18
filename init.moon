export MBOX2DPATH = ...

rect = assert require MBOX2DPATH .. '.rect'
world = assert require MBOX2DPATH .. '.world'


print rect.rectGetSegmentIntersectionIndices 0, 0, 10, 5, 0, 0, 11, 2
