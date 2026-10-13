const { signupSchema } = require('./dist/validators/auth.validator.js');
const result = signupSchema.safeParse({
  fullName: "Het Vaja",
  phone: "9898987878",
  email: "het113@test.com",
  password: "Password123",
  role: "PROVIDER",
  businessName: "",
  address: "123 main street",
  city: "jamnagar",
  state: "Gujarat",
  pincode: "361005",
  taxId: "26954371827"
});
console.log(JSON.stringify(result, null, 2));