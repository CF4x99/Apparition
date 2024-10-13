GobblegumName(name)
{
    return TableLookup("gamedata/stats/zm/zm_statstable.csv", 4, name, 3);
}

ReturnCamoName(index)
{
    return TableLookupColumnForRow("gamedata/weapons/common/attachmenttable.csv", index, 3);
}

ReturnRawCamoName(index)
{
    return TableLookupColumnForRow("gamedata/weapons/common/attachmenttable.csv", index, 4);
}

ReturnAttachmentType(index)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 0, index, 2);
}

ReturnAttachment(index)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 0, index, 4);
}

ReturnAttachmentName(attachment)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 4, attachment, 3);
}

ReturnAttachmentCombinations(attachment)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 4, attachment, 12);
}