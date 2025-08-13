export default class ChromeExtension {
  id: string;
  name: string;
  icon: string;
  disabled: boolean = false;

  constructor(id: string, name: string, icon: string) {
    this.id = id;
    this.name = name;
    this.icon = icon;
  }
}
