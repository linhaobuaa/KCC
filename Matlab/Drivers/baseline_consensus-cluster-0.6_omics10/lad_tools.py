import os
from scripts import union, scale_to_set

def write_lad(s, filename, clust1=None, clust2=None):
    """
    LAD requires a rather obnoxious data format, where you can classify two clusters separately

    This takes an sdata object (s) and writes a datafile in that format
    
    If clust1 and clust2 appear:
    Only clust1 and clust2 classes will be used
    clust1 and clust2 should be the "one sample id per line" type

    clust1 will appear as 1 in the LAD classification, i.e., the 'positive' patterns
    clust2 will appear as 0

    """

    f = open(filename, 'w')
    
    if clust1 is not None:
        s, clusters = scale_to_set(s, clust1, clust2)

        s_ls = [ x.sample_id for x in s.samples ]

        cl_num = 1
        for cl in (os.path.basename(clust1), os.path.basename(clust2)): #Make sure clust1 is 1
            for i in union(s_ls, clusters[cl])[0]:
                f.write(';'.join([s.samples[i].sample_id, str(cl_num), ';'.join([ '%f' % x for x in s.samples[i].data ])]))
                f.write('\n')
    
            cl_num = 0
    else:
        for i in xrange(len(s.samples)):
            f.write(';'.join([s.samples[i].sample_id, '0', ';'.join([ '%f' % x for x in s.samples[i].data ])]))
            f.write('\n')

    f.close()
