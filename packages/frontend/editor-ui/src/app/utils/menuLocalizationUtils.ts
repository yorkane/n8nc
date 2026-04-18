type MenuNode = {
	id: string;
	title: string;
	submenu?: MenuNode[];
};

export function localizeMenuTitlesById<T extends MenuNode>(
	menu: T[],
	titleById: Record<string, string>,
): T[] {
	return menu.map((item) => ({
		...item,
		title: titleById[item.id] ?? item.title,
		submenu: item.submenu?.map((subItem) => ({
			...subItem,
			title: titleById[subItem.id] ?? subItem.title,
		})),
	}));
}
