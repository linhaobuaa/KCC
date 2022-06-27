# Reproduce Ana Fred's Majority voting solution to stabilizing KMeans clustering using OpenEnsembles
# refer to https://naeglelab.github.io/OpenEnsembles/OpenEnsembles.html
import pandas as pd 
import random
import scipy
import matplotlib.pyplot as plt
from sklearn import datasets
import openensembles as oe


def test():
    X, y = datasets.make_moons(n_samples=200, shuffle=True, noise=0.02, random_state=None)
    # print (X.shape, y.shape)
    df = pd.DataFrame(X)
    # print (df)
    dataObj = oe.data(df, [1,2])
    dataObj.plot_data('parent')

    c = oe.cluster(dataObj) 
    K = 2
    name = 'kmeans'
    c.cluster('parent', 'kmeans', name, K, init = 'random', n_init = 1)
    fig = dataObj.plot_data('parent', class_labels=c.labels['kmeans'])
    plt.title('title k=2')
    fig.set_size_inches(4,4)
    fig.savefig('kmeans_keq2.eps', bbox_inches="tight")


def main(dataset):
    data = pd.read_csv("../data/%s.dat" % dataset, header=None)
    # print (data)
    data_labels = pd.read_csv("../data/%s_rclass.dat" % dataset, header=None)
    # print (data_labels)

    groundtruth_num_clusters = len(data_labels[0].unique())
    # print ("groundtruth_num_clusters: ", groundtruth_num_clusters)

    dataObj = oe.data(data, range(1, int(data.shape[1]) + 1))
    
    c = oe.cluster(dataObj)
    c_MV_arr = []
    val_arr = []
    k_values = []
    numSolutions = 100 # number of basic partitions
    for i in range(0, numSolutions):
        name = 'kmeans_' + str(i)
        c.cluster('parent', 'kmeans', name, K=groundtruth_num_clusters, init='random', n_init=1)
        c_MV_arr.append(c.finish_majority_vote(threshold=0.5)) 
        # print (c_MV_arr[i].labels['majority_vote'])
       
        # v = oe.validation(dataObj, c_MV_arr[i])
        # #validation_name = 'point_biserial'
        # validation_name = 'det_ratio'
        # val_name = v.calculate(validation_name, 'majority_vote', 'parent')
        # val_arr.append(v.validation[val_name])
        
        # k_values.append(len(c_MV_arr[i].clusterNumbers['majority_vote']))

    # #Connectedness 
    # fig = plt.figure(5, figsize=(5,5))
    # plt.subplot(2,1,1)
    # plt.plot(range(0,numSolutions), val_arr)
    # plt.title('Validation Metric')
    # plt.xlabel('Number of clusters in Majority Vote')
    # plt.ylabel('DRI')
    # # plt.show()

    # #K
    # plt.subplot(2,1,2)
    # plt.plot(range(0,numSolutions), k_values)
    # plt.title('Majority Vote identified K')
    # plt.xlabel('Number of solutions in Majority Vote')
    # plt.ylabel('K')
    # plt.tight_layout()
    # plt.show()
    # # fig.savefig('validation_k.eps', bbox_inches="tight")

    consensus_labels = c_MV_arr[-1].labels['majority_vote']
    # print (type(consensus_labels))
    scipy.io.savemat("openensemble_%s.mat" % dataset, {"consensus": consensus_labels})


if __name__ == '__main__':
    dataset = "pendigits"
    main(dataset)

