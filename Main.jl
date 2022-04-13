using Pkg
#Pkg.activate("drupal")
Pkg.add("CSV")
Pkg.add("HTTP")
Pkg.add("JSON")
Pkg.add("DataFrames")

#using drupal
using CSV
using HTTP
using JSON
using DataFrames

include("Config.jl")

header = Dict("Authorization" => "Bearer $token", "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json")
function df_to_csv(df, file_name)

    CSV.write(file_name, df)
end

function total_with_platform_access(platform_access)
    platform_access_data = platform_access["data"]

    award_name = []
    award_hq = []
    award_field = []

    for (key, value) in platform_access_data
        naam = value["name"]
        hq = value["hq"]
        field= value["field"]
        #print("$naam \n")
        push!(award_name, naam)
        push!(award_hq, hq)
        push!(award_field, field)
    end
    award_name = replace!(award_name, "MOMENTUM Knowledge Accelerator" => "MKA", "MOMENTUM Routine Immunization Transformation and Equity" => "MRITE",
     "MOMENTUM Integrated Health Resilience" => "MIHR", "MOMENTUM Country and Global Leadership" => "MCGL", 
     "MOMENTUM Safe Surgery in Family Planning and Obstetrics" => "MSSFP", "MOMENTUM Private Healthcare Delivery" => "MPHD", "India: SAMVEG" => "SAMVEG", 
     "India: SAKSHAM" => "SAKSHAM", "Non-MOMENTUM (for news and events)" => "NON-MOM")
    print(award_name)
    df = DataFrame(award= award_name, hq= award_hq, field=award_field)
    print(df)
    return df
end

function get(api_endpoint)
    println("$base_url$api_endpoint")
    hq = []
    field = []
    platform_accessed_dic = Dict()
    response = HTTP.request("GET", "$base_url$api_endpoint"; verbose=1, headers = header)
    mkaDICT = JSON.parse(String(response.body))
    mkaData = mkaDICT["data"]
    df = total_with_platform_access(mkaData["total_with_platform_access"])

    for v in df[!, "award"]
        push!(platform_accessed_dic, v => Dict("Home_Office_or_Headquarters" => 0, "Country_Office" => 0))
    end
    
    delete!(mkaData, "total_with_platform_access")
    mka_home_office = 0;
    mka_country = 0;
    mrite_home_office = 0
    mrite_country = 0
    mihr_home_office = 0
    mihr_country = 0
    mcgl_home_office = 0
    mcgl_country = 0
    usaid_home_office = 0
    usaid_country = 0
    mphd_home_office = 0
    mphd_country = 0
    mssfp_home_office = 0
    mssfp_country = 0
    SAMVEG_home_office = 0
    SAMVEG_country = 0
    SAKSHAM_home_office = 0
    SAKSHAM_country = 0
    NON_MOM_home_office = 0
    NON_MOM_country = 0

    award_name_long = []
    
    for (key, value) in mkaData
        #print(value)
        uid = value["org"][1]["entity_id"]
        #print("$uid - \n")

        #print("$key ->\n")
        
        #print(value["office_type"])
        award = value["awards"][1]["name"]
        #print("$award \n")
        push!(award_name_long, value["awards"][1]["name"])
        # MKA
        if value["awards"][1]["name"] == "MOMENTUM Knowledge Accelerator" && value["office_type"]  == "Home_Office_or_Headquarters"
            mka_home_office = mka_home_office + 1
            platform_accessed_dic["MKA"]["Home_Office_or_Headquarters"] = mka_home_office
        end
        if value["awards"][1]["name"] == "MOMENTUM Knowledge Accelerator" && value["office_type"]  == "Country Office/USAID Mission"
            mka_country = mka_country + 1
            platform_accessed_dic["MKA"]["Country_Office"] = mka_country
        end
        # MRITE
        if value["awards"][1]["name"] == "MOMENTUM Routine Immunization Transformation and Equity" && value["office_type"]  == "Home_Office_or_Headquarters"
            mrite_home_office = mrite_home_office + 1
            platform_accessed_dic["MRITE"]["Home_Office_or_Headquarters"] = mrite_home_office
        end
        if value["awards"][1]["name"] == "MOMENTUM Routine Immunization Transformation and Equity" && value["office_type"]  == "Country Office/USAID Mission"
            mrite_country = mrite_country + 1
            platform_accessed_dic["MRITE"]["Country_Office"] = mrite_country
        end
        # MIHR
        if value["awards"][1]["name"] == "MOMENTUM Integrated Health Resilience" && value["office_type"]  == "Home_Office_or_Headquarters"
            mihr_home_office = mihr_home_office + 1
            platform_accessed_dic["MIHR"]["Home_Office_or_Headquarters"] = mihr_home_office
        end
        if value["awards"][1]["name"] == "MOMENTUM Integrated Health Resilience" && value["office_type"]  == "Country Office/USAID Mission"
            mihr_country = mihr_country + 1
            platform_accessed_dic["MIHR"]["Country_Office"] = mihr_country
        end
        # MCGL
        if value["awards"][1]["name"] == "MOMENTUM Country and Global Leadership" && value["office_type"]  == "Home_Office_or_Headquarters"
            mcgl_home_office = mcgl_home_office + 1
            platform_accessed_dic["MCGL"]["Home_Office_or_Headquarters"] = mcgl_home_office
        end
        if value["awards"][1]["name"] == "MOMENTUM Country and Global Leadership" && value["office_type"]  == "Country Office/USAID Mission"
            mcgl_country = mcgl_country + 1
            platform_accessed_dic["MCGL"]["Country_Office"] = mcgl_country
        end
        # USAID
        if value["awards"][1]["name"] == "USAID" && value["office_type"]  == "Home_Office_or_Headquarters"
            usaid_home_office = usaid_home_office + 1
            platform_accessed_dic["USAID"]["Home_Office_or_Headquarters"] = usaid_home_office
        end
        if value["awards"][1]["name"] == "USAID" && value["office_type"]  == "Country Office/USAID Mission"
            usaid_country = usaid_country + 1
            platform_accessed_dic["USAID"]["Country_Office"] = usaid_country
        end
        # MPHD
        if value["awards"][1]["name"] == "MOMENTUM Private Healthcare Delivery" && value["office_type"]  == "Home_Office_or_Headquarters"
            mphd_home_office = mphd_home_office + 1
            platform_accessed_dic["MPHD"]["Home_Office_or_Headquarters"] = mphd_home_office
        end
        if value["awards"][1]["name"] == "MOMENTUM Private Healthcare Delivery" && value["office_type"]  == "Country Office/USAID Mission"
            mphd_country = mphd_country + 1
            platform_accessed_dic["MPHD"]["Country_Office"] = mphd_country
        end
        # MSSFP
        if value["awards"][1]["name"] == "MOMENTUM Safe Surgery in Family Planning and Obstetrics" && value["office_type"]  == "Home_Office_or_Headquarters"
            mssfp_home_office = mssfp_home_office + 1
            platform_accessed_dic["MSSFP"]["Home_Office_or_Headquarters"] = mssfp_home_office
        end
        if value["awards"][1]["name"] == "MOMENTUM Safe Surgery in Family Planning and Obstetrics" && value["office_type"]  == "Country Office/USAID Mission"
            mssfp_country = mssfp_country + 1
            platform_accessed_dic["MSSFP"]["Country_Office"] = mssfp_country
        end
        # SAMVEG
        if value["awards"][1]["name"] == "India: SAMVEG" && value["office_type"]  == "Home_Office_or_Headquarters"
            SAMVEG_home_office = SAMVEG_home_office + 1
            platform_accessed_dic["SAMVEG"]["Home_Office_or_Headquarters"] = SAMVEG_home_office
        end
        if value["awards"][1]["name"] == "India: SAMVEG" && value["office_type"]  == "Country Office/USAID Mission"
            SAMVEG_country = SAMVEG_country + 1
            platform_accessed_dic["SAMVEG"]["Country_Office"] = SAMVEG_country
        end
        # SAKSHAM
        if value["awards"][1]["name"] == "India: SAKSHAM" && value["office_type"]  == "Home_Office_or_Headquarters"
            SAKSHAM_home_office = SAKSHAM_home_office + 1
            platform_accessed_dic["SAKSHAM"]["Home_Office_or_Headquarters"] = SAKSHAM_home_office
        end
        if value["awards"][1]["name"] == "India: SAKSHAM" && value["office_type"]  == "Country Office/USAID Mission"
            SAKSHAM_country = SAKSHAM_country + 1
            platform_accessed_dic["SAKSHAM"]["Country_Office"] = SAKSHAM_country
        end
        # NON-MOM
        if value["awards"][1]["name"] == "Non-MOMENTUM (for news and events)" && value["office_type"]  == "Home_Office_or_Headquarters"
            NON_MOM_home_office = NON_MOM_home_office + 1
            platform_accessed_dic["NON-MOM"]["Home_Office_or_Headquarters"] = NON_MOM_home_office
        end
        if value["awards"][1]["name"] == "Non-MOMENTUM (for news and events)" && value["office_type"]  == "Country Office/USAID Mission"
            NON_MOM_country = NON_MOM_country + 1
            platform_accessed_dic["NON-MOM"]["Country_Office"] = NON_MOM_country
        end
    end
    print("mka_home_office: $mka_home_office \n")
    print("mka_country: $mka_country \n")
    print("mrite_home_office: $mrite_home_office \n")
    print("mrite_country: $mrite_country \n")
    print("mihr_home_office: $mihr_home_office \n")
    print("mihr_country: $mihr_country \n")
    print("mcgl_home_office: $mcgl_home_office \n")
    print("mcgl_country: $mcgl_country \n")
    print("usaid_home_office: $usaid_home_office \n")
    print("usaid_country: $usaid_country \n")
    print("mphd_home_office: $mphd_home_office \n")
    print("mphd_country: $mphd_country \n")
    print("mssfp_home_office: $mssfp_home_office \n")
    print("mssfp_country: $mssfp_country \n")
    print("SAMVEG_home_office: $SAMVEG_home_office \n")
    print("SAMVEG_country: $SAMVEG_country \n")
    print("SAKSHAM_home_office: $SAKSHAM_home_office \n")
    print("SAKSHAM_country: $SAKSHAM_country \n")
    print("NON_MOM_home_office: $NON_MOM_home_office \n")
    print("NON_MOM_country: $SAKSHAM_country \n")

    for v in df[!, "award"]
        #push!(platform_accessed_dic, v => Dict("Home_Office_or_Headquarters" => 0, "Country_Office" => 0))
        push!(hq, platform_accessed_dic[v]["Home_Office_or_Headquarters"])
        push!(field, platform_accessed_dic[v]["Country_Office"])
    end
    #return JSON.parse(String(response.body))
    #award_name_long = unique(award_name_long)
    #print(award_name_long)
    print("++++++++++++++++++++++++++++\n")
    #print(platform_accessed_dic)
    print(hq)
    print("---------------------------------\n")
    print(field)
    df[!, "hq_accessed"] = hq
    df[!, "field_accessed"] = field

    return df
    # award_name_long = replace!(award_name_long, "MOMENTUM Knowledge Accelerator" => "MKA", "MOMENTUM Routine Immunization Transformation and Equity" => "MRITE",
    # "MOMENTUM Integrated Health Resilience" => "MIHR", "MOMENTUM Country and Global Leadership" => "MCGL", 
    # "MOMENTUM Safe Surgery in Family Planning and Obstetrics" => "MSSFP", "MOMENTUM Private Healthcare Delivery" => "MPHD", "India: SAMVEG" => "SAMVEG", 
    # "India: SAKSHAM" => "SAKSHAM", "Non-MOMENTUM (for news and events)" => "NON-MOM")
    #print(award_name_long)
end

function create_locations(api_endpoint, payload_src)
    println("$base_url$api_endpoint")
    df = CSV.read("$payload_src")
    for x in eachrow(df)
        payload = Dict(
        "data" => Dict("type" => "location--location",
        "attributes" => Dict("name" => x.name, "catchment_population" => x.catchment_population,
        "opening_date" => x.opening_date, "closing_date" => x.closing_date,
        "last_update_date" => x.last_update_date),
        "relationships" => Dict(
        "ownership_type" => Dict(
        "data" => Dict("type" => "taxonomy_term--ownership_type", "id" => x.ownership_type)
        ),
        "regulatory_status" => Dict(
        "data" => Dict("type" => "taxonomy_term--location_regulatory_status", "id" => x.regulatory_status)
        ),
        "location_type" => Dict(
        "data" => Dict("type" => "taxonomy_term--location", "id" => x.location_type)
        ),
        "operational_status" => Dict(
        "data" => Dict("type" => "taxonomy_term--location_operational_status", "id" => x.operational_status)
        )#=,
        "parent" => Dict(
        "data" => Dict("type" => "location--location", "id" => x.parent))=#))
        )
        #println(JSON.json(payload))
        HTTP.request("POST", "$base_url$api_endpoint", headers = header, [], JSON.json(payload))
    end
    #
end

#get("dataSets?de=3.2.1&rel_period=previous_quarter")
print("=========================================")
df = get("dataSets?de=3.2.1&rel_period=Q1&year=2022")
df_to_csv(df, "momentum_location_loader/3_2_1_Q1_2022.csv")
#get("dataSets?de=3.2.1&rel_period=Q2")
#create_locations("locations", "Julia_intro/locations.csv")
#results = JSON.parse(String(response.body))

#drupal.greet()
