GobblegumName(name)
{
    return TableLookupIString("gamedata/stats/zm/zm_statstable.csv", 4, name, 3);
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
    return TableLookupIString("gamedata/weapons/common/attachmenttable.csv", 4, attachment, 3);
}

ReturnAttachmentCombinations(attachment)
{
    return TableLookup("gamedata/weapons/common/attachmenttable.csv", 4, attachment, 12);
}