#!/usr/bin/env python2.7

import sys
import csv
from itertools import izip
import argparse
import os

def cvtChrom(x):
    if x.isdigit():
        return int(x)
    else:
        return x

def vcf2mafEvent(chrom,pos,ref,alt):
    delta=len(ref)-len(alt)
    refN=ref
    altN=alt
    if delta==0:
        endPos=pos
        startPos=pos
    elif delta>0:
        endPos=str(int(pos)+len(refN)-1)
        startPos=str(int(pos)+1)
        refN=refN[1:]
        if len(altN)==1:
            altN='-'
        else:
            altN=altN[1:]
    else:
        endPos=str(int(pos)+1)
        startPos=pos
        refN="-"
        altN=altN[1:]
    return (chrom,startPos,endPos,refN,altN)
    
def populateSeqFileDB(seqF):
    seqDb=dict()
    with open(seqF) as fp:
        for line in fp:
            (tag, seq)=line.strip().split()
            #if len(seq)==3:
            (chrom,region)=tag.split(":")
            (start,end)=[int(x) for x in region.split("-")]
            pos=end-1
            seqDb["%s:%d-%d" % (chrom,pos,pos)]=seq.upper()
    return seqDb

def populateTargedDB(fname):
    tsites=set()
    with open(fname) as fp:
        for line in fp:
            tsites.add(line.strip())
    return tsites

#seqDataFil=list()
#targetedFiles=list()
#exacFile=""
#origMAFFile=""

parser = argparse.ArgumentParser(description="Merge Extra Columns onto MAF")
parser.add_argument('--triNuc',nargs="*",help="TriNucleotide File")
parser.add_argument('--targeted',nargs="*",help="Targeted Regions file (IMPACT410)")
parser.add_argument('--exac',help="ExAC File")
parser.add_argument('--maf',help="Maf to add columns to")
args = parser.parse_args()

if not args.maf:
    print "You are missing the maf file. "
    parser.print_help()
    exit(1)

seqDataFile=args.triNuc
targetedFiles=args.targeted
exacFile=args.exac
origMAFFile=args.maf

## Gather triNuc info
triNucFilenames = list()
seqDbList = list()
if seqDataFile:
    for seqF in seqDataFile:
        triNucFilenames.append(os.path.basename(seqF).split(".")[0])
        seqDbList.append(populateSeqFileDB(seqF).copy())

## Gather targeted info
targetedList = list()
targetedFilenames = list()
if targetedFiles:
    for targetF in targetedFiles:
        targetedFilenames.append(os.path.basename(targetF).split(".")[1])
        targetedList.append(populateTargedDB(targetF).copy())

## Populate exacDb
exacDb=dict()
if exacFile:
    with open(exacFile) as fp:
        line=fp.readline()
        while line.startswith("##"):
            line=fp.readline()
        header=line[1:].strip().split()
        cin=csv.DictReader(fp,fieldnames=header,delimiter="\t")
        for r in cin:
            if r["INFO"]!=".":
                info=dict()
                parseInfo=[x.split("=") for x in r["INFO"].split(";")]
                for ((key,val),cType) in izip(parseInfo,(int,int,float)):
                    info[key]=cType(val)

                (chrom,start,end,ref,alt)=vcf2mafEvent(r["CHROM"],r["POS"],r["REF"],r["ALT"])

                exacDb["chr%s:%s-%s" % (chrom,start,end)]=info

## create extra cols depending on what was given as input, yo!
extra_cols=list()
extra_cols.extend(triNucFilenames)
extra_cols.extend(targetedFilenames)
extra_cols.extend(["t_var_freq","n_var_freq"])

if exacFile:
    extra_cols.extend(["ExAC_AC","ExAC_AN"])

events=dict()
with open(origMAFFile) as fp:
    commentHeader=fp.readline().strip()
    cin=csv.DictReader(fp,delimiter="\t")
    for r  in cin:
        if r["Reference_Allele"]!=r["Tumor_Seq_Allele1"]:
            alt=r["Tumor_Seq_Allele1"]
        elif r["Reference_Allele"]!=r["Tumor_Seq_Allele2"]:
            alt=r["Tumor_Seq_Allele2"]
        else:
            print >>sys.stderr, "Should never get here"
            print >>sys.stderr
            print >>sys.stderr, r
            print >>sys.stderr
            sys.exit()
        chrom=r["Chromosome"]
        if chrom.startswith("chr"):
            chrom=chrom[3:]
        pos=r["Chromosome"]+":"+r["Start_Position"]+"-"+r["End_Position"]
        tag=pos+":"+r["Reference_Allele"]+":"+alt
        label=tag+"::"+r["Tumor_Sample_Barcode"]+":"+r["Matched_Norm_Sample_Barcode"]
        r["Chromosome"]=cvtChrom(chrom)
        r["POS"]=pos
        r["TAG"]=tag
        r["LABEL"]=label

        if seqDbList:
            for k in range(0,len(triNucFilenames)):
                currentSeqDb = seqDbList[k]
                if pos in currentSeqDb:
                    r[triNucFilenames[k]]=currentSeqDb[pos]
                else:
                    r[triNucFilenames[k]]=""
                    
        if targetedFilenames:
            for j in range(0,len(targetedFilenames)):
                r[targetedFilenames[j]]="T" if pos in targetedList[j] else "F"

        if r["t_depth"]=="":
            print >>sys.stderr, label
            r["t_depth"]=str(int(r["t_alt_count"])+int(r["t_ref_count"]))
        r["t_var_freq"]=float(r["t_alt_count"])/float(r["t_depth"])

        if r["n_alt_count"]=="":
            r["n_var_freq"]="-"
        else:
            if r["n_depth"]=="":
                r["n_depth"]=str(int(r["n_alt_count"])+int(r["n_ref_count"]))
            if int(r["n_depth"])>0:
                r["n_var_freq"]=float(r["n_alt_count"])/float(r["n_depth"])
            else:
                r["n_var_freq"]=0.0

        if exacFile:
            if pos in exacDb:
                r["ExAC_AC"]=exacDb[pos]["AC"]
                #r["ExAC_AF"]=exacDb[pos]["AF"]
                r["ExAC_AN"]=exacDb[pos]["AN"]

        events[label]=r

outFields=cin.fieldnames+["POS","TAG","LABEL"] + extra_cols
cout=csv.DictWriter(sys.stdout,outFields,delimiter="\t",lineterminator="\n")

print commentHeader

#import annotateMAF
#annotateMAF.printAnnotation()

cout.writeheader()
for ki in sorted(events):
    cout.writerow(events[ki])



