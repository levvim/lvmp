#!/usr/bin/env python3

# This script contains a class to create a neoantigensStandardized file.

# class
class helper_funcs(object):
    '''
    Class with helper functions.
    '''

    # function to read in netmhc calls
    def read_netmhc_calls(self, sme):
        '''
        Reads in netmhc output.
        '''
        with open(sme, "r") as f:
            lines = [l.strip("\n").split() for l in f.readlines()]
        # peptide, affinity, peptide name, allele
        lines = [[l[1], l[3], l[-2], l[-1]] for l in lines if l != [] and l[0] == "0"]
        return lines

    def organize_pairs(self, wt_sme, mt_sme):
        '''
        Takes the read-in netmhc calls of WT and MT and prepares 
        them for writing to file.
        '''
        data = []
        for w,m in zip(wt_sme, mt_sme):
            wt_kd, mt_kd = w[1], m[1]
            hla = m[-1]
            if float(mt_kd) < 500:
                mut_id = "_".join(m[-2].split("_")[:-1])
                sample_name = mut_id.split("_")[-1]
                wt_pep, mt_pep = w[0], m[0]
                hla = hla.split("-")[1].replace(":", "")
                stuff = [mut_id, mut_id, sample_name, wt_pep, mt_pep, hla, wt_kd, mt_kd]
                data.append(stuff)
        return data

    def get_hlas(self, hla):
        '''
        Get HLAs.
        '''
        # read in HLAs
        with open(hla, "r") as f:
            lines = [l.strip("\n").split("\t") for l in f.readlines()]

        # function to convert HLA to proper format
        def convert_HLA_format(hla):
            hla = hla.split("-")[1].replace(":", "")
            return hla

        hla_dict = {}
        for sme in lines:
            hlas = ",".join([convert_HLA_format(i) for i in sme[0].split(",")])
            hla_dict[sme[0]] = hlas
        return hla_dict

################################################################################
##!/usr/bin/env python3
#
## This script contains a class to create a neoantigensStandardized file.
#
## class
#class helper_funcs(object):
#    '''
#    Class with helper functions.
#    '''
#
#    # function to read in netmhc calls
#    def read_netmhc_calls(self, sme):
#        '''
#        Reads in netmhc output.
#        '''
#        with open(sme, "r") as f:
#            lines = [l.strip("\n").split() for l in f.readlines()]
#        # peptide, affinity, peptide name, allele
#        lines = [[l[1], l[3], l[-2], l[-1]] for l in lines if l != [] and l[0] == "0"]
#        return lines
#
#    def organize_pairs(self, wt_sme, mt_sme):
#        '''
#        Takes the read-in netmhc calls of WT and MT and prepares 
#        them for writing to file.
#        '''
#        data = []
#        for w,m in zip(wt_sme, mt_sme):
#            wt_kd, mt_kd = w[1], m[1]
#            hla = m[-1]
#            if float(mt_kd) < 500:
#                mut_id = "_".join(m[-2].split("_")[:-1])
#                sample_name = mut_id.split("_")[-1]
#                wt_pep, mt_pep = w[0], m[0]
#                hla = hla.split("-")[1].replace(":", "")
#                stuff = [mut_id, sample_name, wt_pep, mt_pep, hla, wt_kd, mt_kd]
#                data.append(stuff)
#        return data
#
#    def get_hlas(self):
#        '''
#        Get HLAs.
#        '''
#        # read in HLAs
#        with open("../../data/hlas.txt", "r") as f:
#            lines = [l.strip("\n").split("\t") for l in f.readlines()]
#
#        # function to convert HLA to proper format
#        def convert_HLA_format(hla):
#            hla = hla.split("-")[1].replace(":", "")
#            return hla
#
#        hla_dict = {}
#        for sme in lines:
#            hlas = ",".join([convert_HLA_format(i) for i in sme[1].split(",")])
#            hla_dict[sme[0]] = hlas
#        return hla_dict
#
