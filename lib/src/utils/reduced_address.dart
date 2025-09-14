String reducedAddress(String address, {int take = 2}){
  if(address.isEmpty) return "";
    final parts = address.split(",");
    return parts.take(take).join(",").trim();

}